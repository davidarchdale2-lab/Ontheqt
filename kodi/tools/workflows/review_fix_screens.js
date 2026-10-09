export const meta = {
  name: 'plezy-review-fix',
  description: 'Adversarial review (two lenses) then skeptical fix per screen group of the Plezy Kodi add-on',
  phases: [{ title: 'Review', detail: 'two independent reviewers per group' }, { title: 'Fix', detail: 'one fixer per group re-verifies each finding before changing anything' }],
}

const ADDON = '/home/user/Ontheqt/kodi/script.plezy.native'
const T = ADDON + '/resources/skins/Main/1080i/templates'
const SCRATCH = '/tmp/claude-0/-home-user-Ontheqt/07496bcc-523a-532c-a040-778fccff4d99/scratchpad'
const R1 = 'e748c89' // git commit holding the r1 add-on exactly as uploaded

const COMMON = `
You are reviewing part of script.plezy.native (${ADDON}), a Kodi add-on (PM4K / plex-for-kodi fork) whose interface was
just ported to look and behave like the official Plezy app (Flutter source: /home/user/edde746/plezy). Kodi does all
playback; the UI is Kodi WindowXML templates (ibis, ${T}) rendered at runtime, plus Python window classes
(lib/windows/*.py) and Kodi-free helpers (lib/plezy_*.py). Nothing has ever been run in real Kodi (none is available
here), so the real risk is things only a careful read can catch. r1 (the add-on before the port) is git commit ${R1}:
compare with  git -C /home/user/Ontheqt diff ${R1} HEAD -- <path>  and  git show ${R1}:kodi/script.plezy.native/<path>.

Read /home/user/Ontheqt/kodi/PLEZY_DESIGN.md first (conventions, shared includes, textures, verified Kodi behaviour).

Tools (all read-only for reviewers):
- python3 -I /home/user/Ontheqt/kodi/tools/validate.py ${ADDON} ${SCRATCH}/work_<you> ${SCRATCH}/baseline_1080 ${SCRATCH}/baseline_43 --only <name fragments>
  renders all templates x 5 themes x 4 indicator styles at 1080p and 4:3 into <work>/render_1080/<theme>/<style>/script-plex-<name>.xml
  and <work>/render_43/... and checks against r1.
- python3 -I /home/user/Ontheqt/kodi/tools/preview_layout.py ${ADDON} <rendered.xml> <scenario.json> <out.png>  (approximate PNG
  with mock data; scenarios in /home/user/Ontheqt/kodi/tools/preview/*.json; read PNGs with your Read tool; it does not resolve
  $LOCALIZE[], disabled-button text or Kodi-only features, and fonts differ). Write PNGs to ${SCRATCH}/review_<you>/.
- Kodi source for exact behaviour: curl -sSfL https://raw.githubusercontent.com/xbmc/xbmc/Omega/xbmc/guilib/<File>.cpp (GUIControlGroupList,
  GUIBaseContainer, GUIFixedListContainer, GUITextBox, GUIButtonControl, GUIControlFactory, GUIListGroup, GUIInfoManager...). Cite it when a
  Kodi-behaviour claim decides a finding. The Kodi Omega skin docs (kodi.wiki) can be fetched too.
- pytest: python3 -m pytest /home/user/Ontheqt/kodi/tests. py_compile: python3 -I -m py_compile <file>.
Delete any __pycache__ you create under /home/user/Ontheqt/kodi.

Do NOT modify any file in /home/user/Ontheqt (reviewers). Scratch files go under ${SCRATCH}/review_<you>/.
Do NOT run state-changing git commands (read-only git is fine).

A finding must be real and demonstrable: quote the exact lines, state the concrete failure (what the user sees or what raises),
and say how you know (read code, rendered output, Kodi source). No style nits, no "consider", no speculation about code you
did not read. If a claim depends on Kodi behaviour you are unsure of, verify against Kodi source or mark confidence low.
An empty findings list is a valid, good result when the code is right. Prefer fewer, correct, high-value findings.
`

const FINDINGS = {
  type: 'object',
  properties: {
    group: { type: 'string' },
    lens: { type: 'string' },
    what_i_checked: { type: 'array', items: { type: 'string' }, description: 'concrete checks performed' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          severity: { type: 'string', enum: ['blocker', 'major', 'minor'], description: 'blocker = crash/unusable/data loss/screen unreachable; major = visibly wrong or a feature broken; minor = polish that a user would notice' },
          confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
          file: { type: 'string' },
          where: { type: 'string', description: 'line numbers / control id / function' },
          issue: { type: 'string' },
          evidence: { type: 'string', description: 'quoted code, render output, or Kodi source reference proving it' },
          failure: { type: 'string', description: 'what the user sees or what raises, with a concrete scenario' },
          suggested_fix: { type: 'string' },
        },
        required: ['id', 'severity', 'confidence', 'file', 'where', 'issue', 'evidence', 'failure', 'suggested_fix'],
      },
    },
  },
  required: ['group', 'lens', 'what_i_checked', 'findings'],
}

const LENS_A = `LENS A - KODI CORRECTNESS AND THE PYTHON/TEMPLATE CONTRACT. Hunt for things that break in real Kodi:
1. Navigation: for every window in the group, start at its default control and follow onup/ondown/onleft/onright (including conditional
   ones: Kodi uses the FIRST matching numeric target, GUIAction::GetNavigation) and Python-driven setFocusId. Every focusable control must be
   reachable and must have a way back; no dead ends or targets that point to invisible/nonexistent controls; Back/Menu must still work.
2. Visibility/animation conditions: syntax valid Kodi booleans, no references to window properties the Python never sets (grep the Python
   for setProperty/setBoolProperty names used in $INFO[Window.Property(..)] and Window.Property(..) conditions in the template), inverted
   conditions, conditions that hide a control that must stay focusable (allowhiddenfocus).
3. Python: every control ID the class references exists in the rendered template with a compatible control type (list vs group vs button);
   new code has no NameError/AttributeError/KeyError/None paths; try/except where it should be; no network call or blocking work inside
   onFocus/onAction/focus handlers; thread-safety where the class uses background tasks; behaviour that existed in r1 and was lost
   (diff against ${R1}) - e.g. a button whose onClick branch disappeared, a list that is no longer filled, a property removed.
4. ibis/XML: attributes Kodi ignores or rejects (e.g. height max on non-textbox, texture border values larger than the texture,
   usealttexture on a plain button, <aspectratio> on wrong control types), duplicate control ids that matter, controls outside the
   screen, textures that do not exist (the validator checks static ones; check $INFO-built paths).
5. Kodi list/grouplist semantics that the templates assume (focusedlayout condition, itemlayout height vs list height, grouplist
   usecontrolcoords/align, pagecontrol/scrollbar wiring, fixed vs wrap lists) - verify against Kodi source when it decides a finding.`

const LENS_B = `LENS B - PLEZY FIDELITY AND ROBUSTNESS OF WHAT THE USER SEES. Hunt for:
1. Fidelity: compare each screen to the corresponding Plezy TV screen in /home/user/edde746/plezy (find the widget files; the specs in
   ${SCRATCH}/specs/<group>.json list them). Wrong order/labels/icons/colours/focus language/geometry that a Plezy user would see as a
   different app. Only report differences that matter and are achievable in Kodi; the README of known gaps is in the implementer report
   ${SCRATCH}/reports/<group>.json or ${SCRATCH}/reports2/<group>.json (known_gaps, risks) - do not re-report listed gaps unless the
   workaround is wrong, but DO verify the 'risks' list items: each is something a reviewer should check.
2. Render and LOOK: render the group's templates, run the scenario previews in /home/user/Ontheqt/kodi/tools/preview/ (and write new
   scenarios for states they do not cover: long titles, no artwork, empty lists, error/loading, 4:3 via the render_43 output) and read the PNGs.
   Report overlaps, clipped/overflowing text, illegible contrast (text on artwork without scrim), misaligned rows, controls off-screen,
   focus rings clipped by a parent list/grouplist, wrong sizes at 4:3.
3. Themes: the add-on still offers Modern / Modern (dotted) / Modern (colored) / Classic button themes (theme.assets / theme.* in
   lib/templating/context.py). Check the group's templates render and look sane in each (render_1080/<theme>/<style>); a Plezy-only
   assumption that makes another theme unusable (e.g. a texture that only exists in the plezy theme) is a finding.
4. Strings: every $ADDON[script.plezy.native <id>] and T(<id>, ...) used by the group exists in resources/language/resource.language.en_gb/strings.po
   (or is a Kodi core string) and reads naturally; no leftover English hard-coded in templates that was localised before; sentence case.
5. Python-set text: the Kodi-free helper modules produce the exact text Plezy shows for representative inputs (run them with realistic
   data from a REPL/test); check edge cases: missing year/duration/ratings, episode without index, empty summary, very long title.`

const GROUPS = {
  'movie-detail': { only: 'pre_play', files: `templates/script-plex-pre_play.xml.tpl, script-plex-pre_play-wl.xml.tpl, includes/pre_play_rail_row.xml.tpl, includes/wl_*.xml.tpl; lib/windows/preplay.py, lib/plezy_movie_detail.py; tests/test_movie_detail.py` },
  'show-detail': { only: 'seasons', files: `templates/script-plex-seasons.xml.tpl; lib/windows/subitems.py (ShowWindow; ArtistWindow belongs to music), lib/plezy_show_detail.py; tests for it` },
  'season-episodes': { only: 'episodes', files: `templates/script-plex-episodes.xml.tpl, includes/episodes_rail_row.xml.tpl; lib/windows/episodes.py, lib/plezy_season_episodes.py; tests/test_season_episodes.py` },
  'player-osd': { only: 'seek_dialog,video_player,video_current_playlist', files: `templates/script-plex-seek_dialog.xml.tpl, script-plex-video_player.xml.tpl, script-plex-video_current_playlist.xml.tpl, includes/seek_*.xml.tpl; lib/windows/seekdialog.py, videoplayer.py, lib/plezy_player_osd.py; tests` },
  'search': { only: 'search', files: `templates/script-plex-search.xml.tpl, includes/search_*.xml.tpl, includes/plezy_chip.xml.tpl, includes/plezy_state_message.xml.tpl; lib/windows/search.py, lib/plezy_search.py; tests/test_search*.py` },
  'settings-dialogs': { only: 'settings,options_dialog,dropdown,info,busy,blackout,video_settings,track_context', files: `templates/script-plex-settings*.xml.tpl, script-plex-options_dialog*.xml.tpl, script-plex-dropdown*.xml.tpl, script-plex-info.xml.tpl, script-plex-busy*.xml.tpl, script-plex-blackout_dialog.xml.tpl, script-plex-video_settings_dialog.xml.tpl, script-plex-track_context.xml.tpl and their includes (plezy_group_row, plezy_switch, plezy_menu_row, plezy_dialog*, ...); lib/windows/settings.py, dialog.py, optionsdialog.py, dropdown.py, info.py, busy.py, blackoutdialog.py, playersettings.py; tests` },
  'profiles-signin': { only: 'user_select,pre_signin,pin_login,refresh_code,plex_pass,signin,background', files: `templates/script-plex-user_select.xml.tpl, script-plex-pre_signin.xml.tpl, script-plex-pin_login.xml.tpl, script-plex-refresh_code.xml.tpl, script-plex-plex_pass.xml.tpl, script-plex-signin_*.xml.tpl, script-plex-background.xml.tpl and their includes (plezy_auth_brand, plezy_signin_button, profile_tile, pin_dialog, pin_key, mini_player_button); lib/windows/userselect.py, signin.py, background.py; tests` },
  'music-photos-lists': { only: 'album,artist,music_player,music_current_playlist,playlists,playlist,person,genres,photo,slideshow,listview', files: `templates/script-plex-album.xml.tpl, artist, music_player, music_current_playlist, playlists, playlist, person, genres, photo, slideshow, listview-16x9, listview-square and includes/music_*.xml.tpl, playlist_item_row, library_list_*; lib/windows/tracks.py, musicplayer.py, currentplaylist.py, playlists.py, playlist.py, person.py, genres.py, photos.py, slidehshow.py, library.py (list views), subitems.py ArtistWindow, lib/plezy_music.py; tests/test_music_photos_lists.py` },
  'shared-and-r2': { only: 'home,posters,squares,listview,library,default', files: `the revision-2 and shared pieces: templates/script-plex-home.xml.tpl, script-plex-posters*.xml.tpl, script-plex-squares.xml.tpl, default.xml.tpl, library.xml.tpl, library_posters.xml.tpl, includes/default_background, plezy_hub_card, plezy_action_button, plezy_row_header, plezy_spinner, plezy_scrims, hub_*layout_*, watched_indicator, themed_button; lib/plezy_ui.py, lib/windows/home.py (spotlight, hub icons, hub.focus.id), lib/templating/context.py, lib/templating/*.py, lib/util.py THEME_VERSION, lib/addonsettings.py, resources/settings.xml defaults, kodi/tools/*.py (texture generator, renderer, checker, previewer, zip builder), addon.xml/changelog/LOCAL-CHANGES/INSTALL notes consistency. This group was never reviewed adversarially: also check the install/upgrade path (r1 -> r3: settings that changed default, THEME_VERSION re-render, DEF_THEME 'plezy' selectable, removed/renamed textures still referenced by an untouched template or by Python (grep every script.plex/ path in lib/*.py and lib/windows/*.py)).` },
}

const FIX = `
You are the FIXER for one screen group of script.plezy.native (${ADDON}). Two independent reviewers produced findings (below).
Your job is to be the skeptic: for EVERY finding, independently verify it (read the exact code, render/preview, check Kodi source) BEFORE
changing anything. Classify each as confirmed, rejected (explain why with evidence), or already-handled. Then fix every confirmed
finding of any severity that is a real defect, minimally and in the existing style, without widening scope or restyling.

Rules:
- Edit only files that belong to your group (listed below) plus brand-new files you create for it. A confirmed finding whose fix needs a
  shared file or another group's file (plezy_hub_card, plezy_action_button, context.py, strings.po, util.py, kodi/tools/*, other screens)
  goes in cross_group_requests with the exact change; do not edit it. Exception: if you are the 'shared-and-r2' fixer you own the shared files.
- Never run state-changing git commands. Do not delete reviewers' notes.
- Keep every control ID, property, navigation path and behaviour the Python relies on. Do not add network calls to focus handlers.
- ibis limits: no and/or inside expressions except in {% if %}; no string concat; no filters inside arithmetic (use {% with %}); vscale for vertical sizes.
- New strings: you may not edit strings.po; use your group's reserved block if you must add one and list it in strings_needed
  (blocks: movie 35100-35119, show 35120-35139, episodes 35140-35159, player 35160-35179, search 35180-35199, settings 35200-35219,
  profiles 35220-35239, music 35240-35259, shared 35260-35279).
- After fixing: run validate.py --only <fragments> (must be 0 problems at both resolutions), py_compile every Python file you changed,
  the unit tests, and re-render/preview any screen you changed and LOOK at it. Add or extend a unit test for each Python logic fix.
- Remove __pycache__ you create.
Return the report in the schema. 'rejected' entries need real evidence; do not reject to save effort.
`

const FIX_REPORT = {
  type: 'object',
  properties: {
    group: { type: 'string' },
    verdicts: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          finding_id: { type: 'string' },
          verdict: { type: 'string', enum: ['confirmed_fixed', 'confirmed_not_fixed', 'rejected', 'already_handled'] },
          reasoning: { type: 'string' },
          change: { type: 'string', description: 'what you changed, with file and function/control' },
        },
        required: ['finding_id', 'verdict', 'reasoning', 'change'],
      },
    },
    additional_issues_fixed: { type: 'array', items: { type: 'string' }, description: 'defects you found yourself while verifying and fixed' },
    cross_group_requests: { type: 'array', items: { type: 'string' } },
    strings_needed: { type: 'array', items: { type: 'object', properties: { id: { type: 'integer' }, english: { type: 'string' }, used_in: { type: 'string' } }, required: ['id', 'english', 'used_in'] } },
    files_changed: { type: 'array', items: { type: 'string' } },
    validation: { type: 'string', description: 'exact validate.py summary lines, py_compile and pytest results after your changes' },
    remaining_risks: { type: 'array', items: { type: 'string' }, description: 'things that can only be checked on a real Kodi device' },
  },
  required: ['group', 'verdicts', 'additional_issues_fixed', 'cross_group_requests', 'strings_needed', 'files_changed', 'validation', 'remaining_risks'],
}

const KEYS = Array.isArray(args) && args.length ? args : Object.keys(GROUPS)
log('groups: ' + KEYS.join(', '))

const results = await pipeline(
  KEYS,
  key => parallel(['A', 'B'].map(lens => () => agent(
    COMMON + `\nYOUR GROUP: ${key}\nFiles in scope (paths relative to ${ADDON}; templates under resources/skins/Main/1080i/): ${GROUPS[key].files}\nValidate with --only ${GROUPS[key].only}\nSpec/reports with context: ${SCRATCH}/specs/${key}.json and ${SCRATCH}/reports/${key}.json or ${SCRATCH}/reports2/${key}.json (when present).\n\n${lens === 'A' ? LENS_A : LENS_B}\n\nReturn your findings (lens "${lens}", group "${key}").`,
    { label: `review-${lens}:${key}`, phase: 'Review', schema: FINDINGS }))),
  (reviews, key) => {
    const ok = reviews.filter(Boolean)
    const all = ok.flatMap(r => r.findings.map(f => ({ ...f, lens: r.lens })))
    log(`${key}: ${all.length} findings from ${ok.length} reviewers`)
    return agent(
      FIX + `\nYOUR GROUP: ${key}\nFiles you own (paths relative to ${ADDON}; templates under resources/skins/Main/1080i/): ${GROUPS[key].files}\nValidate with --only ${GROUPS[key].only}\n\nFINDINGS (JSON):\n${JSON.stringify(all, null, 1)}\n\nReviewer coverage notes:\n${JSON.stringify(ok.map(r => ({ lens: r.lens, checked: r.what_i_checked })), null, 1)}\n\nIf there are no findings, still do a final validate/test run and look at the group's previews once; report accordingly.`,
      { label: `fix:${key}`, phase: 'Fix', schema: FIX_REPORT })
  },
)
return results.filter(Boolean)

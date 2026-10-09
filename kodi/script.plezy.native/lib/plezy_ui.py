# coding=utf-8
"""
Plezy UI helpers for the home screen, ported from edde746/plezy:
 - hub_icon: the leading icon of a hub row (lib/utils/hub_icons.dart)
 - spotlight_fields: the TV spotlight's title, metadata line and summary (lib/widgets/tv_spotlight_background.dart)

Kept free of Kodi imports so they can be tested outside Kodi; callers pass in anything localised.
"""
from __future__ import absolute_import

import datetime

ICON_PATH = 'script.plex/plezy/icons/{0}.png'
SEPARATOR = u' • '

CONTINUE_IDENTIFIERS = ('continueWatching', 'home.continue', 'home.ondeck', 'watchlist.continueWatching')

# Title keywords in match order: the first match wins, so the specific rows come before the broad ones.
TITLE_KEYWORD_ICONS = (
    (('trending',), 'hub_trending'),
    (('popular', 'imdb'), 'hub_popular'),
    (('seasonal',), 'hub_seasonal'),
    (('newly', 'new release'), 'hub_new'),
    (('recently released', 'recent'), 'hub_recent'),
    (('top rated', 'highest rated'), 'hub_star'),
    (('top ',), 'hub_top'),
    (('thriller',), 'hub_thriller'),
    (('comedy', 'comedier'), 'hub_comedy'),
    (('action',), 'hub_action'),
    (('drama',), 'hub_drama'),
    (('fantasy',), 'hub_fantasy'),
    (('science', 'sci-fi'), 'hub_scifi'),
    (('horror', u'skr\xe4ck'), 'hub_horror'),
    (('romance', 'romantic'), 'hub_romance'),
    (('adventure', u'\xe4ventyr'), 'hub_adventure'),
    (('playlist', 'watchlist'), 'hub_playlist'),
    (('unwatched', 'unplayed'), 'hub_unwatched'),
    (('watched', 'played'), 'hub_watched'),
    (('network', 'more from'), 'hub_network'),
    (('actor', 'director'), 'hub_person'),
    (('80', '90', '00'), 'hub_decade'),
    (('rediscover', 'start watching'), 'hub_start'),
    (('rated',), 'hub_star'),
    (('recommended',), 'hub_recommended'),
    (('genre',), 'hub_genre'),
)


def hub_icon(identifier, title):
    """Texture path of the icon shown before a hub row's title."""
    identifier = identifier or ''
    title = (title or '').lower()
    if (identifier in CONTINUE_IDENTIFIERS or 'inprogress' in identifier or 'ondeck' in identifier.lower()
            or 'continue watching' in title or 'on deck' in title):
        return ICON_PATH.format('hub_continue')
    for keywords, icon in TITLE_KEYWORD_ICONS:
        if any(k in title for k in keywords):
            return ICON_PATH.format(icon)
    return ICON_PATH.format('hub_default')


def _text(obj, attr):
    value = getattr(obj, attr, None)
    return u'{0}'.format(value).strip() if value not in (None, False) else u''


def _number(obj, attr):
    try:
        return float(_text(obj, attr) or 0)
    except ValueError:
        return 0.0


def duration_text(ms):
    """Plezy formatDurationTextual: 2h 10m, 45m."""
    minutes = int(round(ms / 60000.0))
    if minutes <= 0:
        return u''
    hours, minutes = divmod(minutes, 60)
    if hours and minutes:
        return u'{0}h {1}m'.format(hours, minutes)
    return u'{0}h'.format(hours) if hours else u'{0}m'.format(minutes)


def full_date(value):
    """'2024-03-03' -> 'March 3, 2024' (the add-on's long episode date)."""
    try:
        d = datetime.datetime.strptime(value[:10], '%Y-%m-%d')
    except (TypeError, ValueError):
        return u''
    return u'{0} {1}, {2}'.format(d.strftime('%B'), d.day, d.year)


def _score(value, image):
    """One rating pair as text. Rotten Tomatoes scores are percentages, the others out of ten."""
    if not value:
        return u''
    image = image or ''
    if image.startswith('rottentomatoes://'):
        label = 'Audience' if ('upright' in image or 'spilled' in image) else 'RT'
        return u'{0} {1}%'.format(label, int(round(value * 10)))
    if image.startswith('imdb://'):
        return u'IMDb {0:.1f}'.format(value)
    if image.startswith('themoviedb://'):
        return u'TMDB {0:.1f}'.format(value)
    return u'{0:.1f}'.format(value)


def ratings_text(obj):
    parts = [_score(_number(obj, 'rating'), _text(obj, 'ratingImage')),
             _score(_number(obj, 'audienceRating'), _text(obj, 'audienceRatingImage'))]
    return SEPARATOR.join(p for p in parts if p)


# Plezy's FittedMetadataLine drops parts by priority until the line fits: ratings first, then the content rating,
# then the runtime; the episode label and the date/year always stay. Kodi can't measure text for us, so the budget
# is in characters: about what the spotlight's 1300px bold line holds at Estuary's font13.
META_BUDGET = 70
DROP_ORDER = ('ratings', 'content_rating', 'duration')


def fit_meta(parts, budget=META_BUDGET):
    """parts: [(kind, text)] in display order -> the joined line, dropping DROP_ORDER kinds until it fits."""
    parts = [(k, t) for k, t in parts if t]
    for kind in DROP_ORDER:
        if len(SEPARATOR.join(t for _, t in parts)) <= budget:
            break
        parts = [(k, t) for k, t in parts if k != kind]
    return SEPARATOR.join(t for _, t in parts)


def spotlight_fields(obj, season_fmt=u'S{}', episode_fmt=u'E{}', hide_summary=False, hide_title=False,
                     hide_ratings=False, meta_budget=META_BUDGET):
    """
    Title, metadata line and summary for the home spotlight, in Plezy's order:
    S1 · E3 · title  •  ratings  •  content rating  •  duration  •  air date (episodes) / year
    """
    kind = _text(obj, 'type')
    if kind == 'episode':
        title = _text(obj, 'grandparentTitle') or _text(obj, 'title')
    elif kind == 'season':
        title = _text(obj, 'parentTitle') or _text(obj, 'title')
    else:
        title = _text(obj, 'grandparentTitle') or _text(obj, 'title')

    parts = []  # (kind, text)
    if kind == 'episode':
        label = []
        if _text(obj, 'parentIndex'):
            label.append(season_fmt.format(_text(obj, 'parentIndex')))
        if _text(obj, 'index'):
            label.append(episode_fmt.format(_text(obj, 'index')))
        if not hide_title and _text(obj, 'title'):
            label.append(_text(obj, 'title'))
        if label:
            parts.append(('label', u' \xb7 '.join(label)))
    elif kind == 'season':
        parts.append(('label', _text(obj, 'title')))
    elif kind in ('album', 'track') and _text(obj, 'parentTitle'):
        # album: the artist; track: the album (the artist is already the title)
        parts.append(('label', _text(obj, 'parentTitle')))

    if not hide_ratings:
        parts.append(('ratings', ratings_text(obj)))
    content_rating = _text(obj, 'contentRating')
    if content_rating:
        parts.append(('content_rating', content_rating.split('/', 1)[-1]))
    parts.append(('duration', duration_text(_number(obj, 'duration'))))  # empty when the item has none
    if kind == 'episode' and _text(obj, 'originallyAvailableAt'):
        parts.append(('date', full_date(_text(obj, 'originallyAvailableAt'))))
    elif _text(obj, 'year'):
        parts.append(('date', _text(obj, 'year')))

    return {
        'title': title,
        'meta': fit_meta(parts, meta_budget),
        'summary': u'' if hide_summary else _text(obj, 'summary'),
    }


# ---- detail screens (lib/screens/media_detail_screen.dart, TV) ----

def episode_label(parent_index, index, season_fmt=u'S{}', episode_fmt=u'E{}'):
    """Plezy formatSeasonEpisodeLabel: 'S1 E3', or '' when either number is missing."""
    season, episode = u'{0}'.format(parent_index or u'').strip(), u'{0}'.format(index or u'').strip()
    if not season or not episode:
        return u''
    return u'{0} {1}'.format(season_fmt.format(season), episode_fmt.format(episode))


def abbreviated_date(value):
    """Plezy formatAbbreviatedDate (DateFormat.yMMMd): '2024-03-03' -> 'Mar 3, 2024'."""
    try:
        d = datetime.datetime.strptime(u'{0}'.format(value)[:10], '%Y-%m-%d')
    except (TypeError, ValueError):
        return u''
    return u'{0} {1}, {2}'.format(d.strftime('%b'), d.day, d.year)


def detail_meta(obj, season_fmt=u'S{}', episode_fmt=u'E{}', hide_ratings=False, budget=META_BUDGET):
    """
    The TV detail hero's metadata line, in Plezy's _tvDetailMetadataParts order:
    S1 E3 (episodes)  •  air date (episodes) / year  •  content rating  •  duration  •  ratings
    Shed to fit: ratings first, then the content rating, then the runtime; label and date always stay.
    """
    kind = _text(obj, 'type')
    parts = []
    if kind == 'episode':
        parts.append(('label', episode_label(_text(obj, 'parentIndex'), _text(obj, 'index'), season_fmt, episode_fmt)))
    if kind == 'episode' and _text(obj, 'originallyAvailableAt'):
        parts.append(('date', abbreviated_date(_text(obj, 'originallyAvailableAt'))))
    elif _text(obj, 'year'):
        parts.append(('date', _text(obj, 'year')))
    content_rating = _text(obj, 'contentRating')
    if content_rating:
        parts.append(('content_rating', content_rating.split('/', 1)[-1]))
    parts.append(('duration', duration_text(_number(obj, 'duration'))))  # empty when the item has none
    if not hide_ratings:
        parts.append(('ratings', ratings_text(obj)))
    return fit_meta(parts, budget)


def season_meta(season, episodes_label=u'Episodes'):
    """A season in the show hero: year  •  N episodes (leafCount)."""
    parts = [_text(season, 'year') or _text(season, 'parentYear')]
    count = int(_number(season, 'leafCount'))
    if count:
        parts.append(u'{0} {1}'.format(count, episodes_label))
    return SEPARATOR.join(p for p in parts if p)


def play_label(parent_index, index, season_fmt=u'S{}', episode_fmt=u'E{}'):
    """Plezy _getPlayButtonLabel for shows: t.discover.playEpisode, 'S1E3' with no space (the metadata line uses
    'S1 E3'). Movies and episodes get no label."""
    season, episode = u'{0}'.format(parent_index or u'').strip(), u'{0}'.format(index or u'').strip()
    if not season or not episode:
        return u''
    return season_fmt.format(season) + episode_fmt.format(episode)

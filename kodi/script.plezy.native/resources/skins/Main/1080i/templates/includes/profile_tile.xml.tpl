{# One row of the Plezy profile switcher (edde746/plezy lib/screens/profile/profile_switch_screen.dart _ProfileTile) at x1.5, for list 101
   of script-plex-user_select.xml.tpl. A row is either a profile tile (1776 x 112, the M3E connected-group shape picked by
   ListItem.Property(group.pos): first / middle / last / only) or the empty-property row at the end, Plezy's full-width outlined stadium
   ("Add profile" there, "Refresh users" here). The list pitch is 115 (3px group gap).
   Focus is a fill only: white @20% (FocusTheme.focusBackgroundDecoration) while the list has focus, selected_fill while the PIN
   dialog (group 400) is open for this row. No scale, no ring.
   Item properties (lib/windows/userselect.py): group.pos, avatar.color (AARRGGBB disc behind the initial), ListItem.Label2 = the initial,
   ListItem.Thumb = the avatar picture, protected (lock badge), active (check icon + no chevron), meta (the muted line).
   params: focused (this is the focused layout) #}
<control type="group">
    <visible>String.IsEmpty(ListItem.Property(empty))</visible>
    {% for pos, tex in [["first", "group-top"], ["middle", "group-mid"], ["last", "group-bottom"], ["only", "group-single"]] %}
    <control type="image">
        <visible>String.IsEqual(ListItem.Property(group.pos),{{ pos }})</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1776</width>
        <height>{{ vscale(112) }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/{{ tex }}.png</texture>
    </control>
    {% if focused %}
    <control type="image">
        <visible>String.IsEqual(ListItem.Property(group.pos),{{ pos }}) + Control.HasFocus(101)</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1776</width>
        <height>{{ vscale(112) }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/{{ tex }}.png</texture>
    </control>
    <control type="image">
        <visible>String.IsEqual(ListItem.Property(group.pos),{{ pos }}) + ControlGroup(400).HasFocus(0)</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>1776</width>
        <height>{{ vscale(112) }}</height>
        <texture border="20" colordiffuse="{{ core.plezy.selected_fill }}">script.plex/plezy/{{ tex }}.png</texture>
    </control>
    {% endif %}
    {% endfor %}

    {# avatar (44lp = 72px): the colour disc and initial show until the picture is there, as in Plezy's frameBuilder #}
    <control type="image">
        <posx>20</posx>
        <posy>{{ vscale(20) }}</posy>
        <width>72</width>
        <height>{{ vscale(72) }}</height>
        <texture>script.plex/plezy/circle.png</texture>
        <colordiffuse>$INFO[ListItem.Property(avatar.color)]</colordiffuse>
    </control>
    <control type="label">
        <posx>20</posx>
        <posy>{{ vscale(20) }}</posy>
        <width>72</width>
        <height>{{ vscale(72) }}</height>
        <font>font13</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>FFFFFFFF</textcolor>
        <label>[B]$INFO[ListItem.Label2][/B]</label>
    </control>
    <control type="image">
        <posx>20</posx>
        <posy>{{ vscale(20) }}</posy>
        <width>72</width>
        <height>{{ vscale(72) }}</height>
        <texture diffuse="script.plex/plezy/circle.png" background="true">$INFO[ListItem.Thumb]</texture>
        <aspectratio>scale</aspectratio>
    </control>
    {# PIN lock badge: ProfileAvatar's surface disc (34% of the avatar) with a filled lock (70%) #}
    <control type="group">
        <visible>!String.IsEmpty(ListItem.Property(protected))</visible>
        <control type="image">
            <posx>70</posx>
            <posy>{{ vscale(70) }}</posy>
            <width>24</width>
            <height>{{ vscale(24) }}</height>
            <texture colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/circle.png</texture>
        </control>
        <control type="image">
            <posx>74</posx>
            <posy>{{ vscale(74) }}</posy>
            <width>16</width>
            <height>{{ vscale(16) }}</height>
            <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/lock.png</texture>
            <aspectratio>keep</aspectratio>
        </control>
    </control>

    <control type="label">
        <posx>114</posx>
        <posy>{{ vscale(18) }}</posy>
        <width>1560</width>
        <height>{{ vscale(42) }}</height>
        <font>font13</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>{% if focused %}true{% else %}false{% endif %}</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>[B]$INFO[ListItem.Label][/B]</label>
    </control>
    {# the muted role line; the active profile starts it with Plezy's check_circle #}
    <control type="image">
        <visible>!String.IsEmpty(ListItem.Property(active))</visible>
        <posx>114</posx>
        <posy>{{ vscale(67) }}</posy>
        <width>22</width>
        <height>{{ vscale(22) }}</height>
        <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/check_circle.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <visible>!String.IsEmpty(ListItem.Property(active))</visible>
        <posx>144</posx>
        <posy>{{ vscale(62) }}</posy>
        <width>1500</width>
        <height>{{ vscale(32) }}</height>
        <font>font10</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$INFO[ListItem.Property(meta)]</label>
    </control>
    <control type="label">
        <visible>String.IsEmpty(ListItem.Property(active))</visible>
        <posx>114</posx>
        <posy>{{ vscale(62) }}</posy>
        <width>1500</width>
        <height>{{ vscale(32) }}</height>
        <font>font10</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>$INFO[ListItem.Property(meta)]</label>
    </control>
    {# chevron_right: Plezy shows it on every tile that is not the active one #}
    <control type="image">
        <visible>String.IsEmpty(ListItem.Property(active)){% if focused %} + !Control.HasFocus(101){% endif %}</visible>
        <posx>1722</posx>
        <posy>{{ vscale(38) }}</posy>
        <width>36</width>
        <height>{{ vscale(36) }}</height>
        <texture colordiffuse="{{ core.plezy.muted }}">script.plex/plezy/icons/chevron_right.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    {% if focused %}
    <control type="image">
        <visible>String.IsEmpty(ListItem.Property(active)) + Control.HasFocus(101)</visible>
        <posx>1722</posx>
        <posy>{{ vscale(38) }}</posy>
        <width>36</width>
        <height>{{ vscale(36) }}</height>
        <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/chevron_right.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    {% endif %}
</control>

{# the last row: a full-width outlined stadium, Plezy's "Add profile" button, here refreshing the user list #}
<control type="group">
    <visible>!String.IsEmpty(ListItem.Property(empty))</visible>
    {% if focused %}
    <control type="image">
        <visible>Control.HasFocus(101)</visible>
        <posx>0</posx>
        <posy>{{ vscale(9) }}</posy>
        <width>1776</width>
        <height>{{ vscale(64) }}</height>
        <texture border="32" colordiffuse="{{ core.plezy.focus_bg }}">script.plex/plezy/pill-64.png</texture>
    </control>
    {% endif %}
    <control type="image">
        <posx>0</posx>
        <posy>{{ vscale(9) }}</posy>
        <width>1776</width>
        <height>{{ vscale(64) }}</height>
        <texture border="32" colordiffuse="{{ core.plezy.outline }}">script.plex/plezy/outline-pill-64.png</texture>
    </control>
    <control type="label">
        <posx>0</posx>
        <posy>{{ vscale(9) }}</posy>
        <width>1776</width>
        <height>{{ vscale(64) }}</height>
        <font>font12</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>[B]$ADDON[script.plezy.native 32980][/B]</label>
    </control>
</control>

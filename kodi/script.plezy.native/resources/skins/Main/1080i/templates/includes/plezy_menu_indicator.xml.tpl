{# Trailing indicator of a Plezy menu row (see plezy_menu_row.xml.tpl): maps the PM4K indicator texture the Python hands
   over in ListItem.Thumb to Plezy's icons (check -> check, arrows -> arrow_upward / arrow_downward, remove -> close);
   any other image is drawn as is. Drawn only while the row carries with.indicator.
   params: ix (x of the 27px slot), slot (extra visible condition, e.g. the has.submenu state), col (colour) #}
<control type="image">
    <visible>{{ slot }} + [String.Contains(ListItem.Thumb,check) | String.Contains(ListItem.Thumb,circle-19)]</visible>
    <posx>{{ ix }}</posx><posy>{{ vscale(19) }}</posy><width>27</width><height>{{ vscale(27) }}</height>
    <texture colordiffuse="{{ col }}">script.plex/plezy/icons/check.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>{{ slot }} + String.Contains(ListItem.Thumb,arrow-down)</visible>
    <posx>{{ ix }}</posx><posy>{{ vscale(19) }}</posy><width>27</width><height>{{ vscale(27) }}</height>
    <texture colordiffuse="{{ col }}">script.plex/plezy/icons/arrow_downward.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>{{ slot }} + String.Contains(ListItem.Thumb,arrow-up)</visible>
    <posx>{{ ix }}</posx><posy>{{ vscale(19) }}</posy><width>27</width><height>{{ vscale(27) }}</height>
    <texture colordiffuse="{{ col }}">script.plex/plezy/icons/arrow_upward.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>{{ slot }} + String.Contains(ListItem.Thumb,remove)</visible>
    <posx>{{ ix }}</posx><posy>{{ vscale(19) }}</posy><width>27</width><height>{{ vscale(27) }}</height>
    <texture colordiffuse="{{ col }}">script.plex/plezy/icons/close.png</texture>
    <aspectratio>keep</aspectratio>
</control>
<control type="image">
    <visible>{{ slot }} + !String.IsEmpty(ListItem.Thumb) + !String.Contains(ListItem.Thumb,check) + !String.Contains(ListItem.Thumb,circle-19) + !String.Contains(ListItem.Thumb,arrow-) + !String.Contains(ListItem.Thumb,remove)</visible>
    <posx>{{ ix }}</posx><posy>{{ vscale(19) }}</posy><width>27</width><height>{{ vscale(27) }}</height>
    <texture colordiffuse="{{ col }}">$INFO[ListItem.Thumb]</texture>
    <aspectratio>keep</aspectratio>
</control>

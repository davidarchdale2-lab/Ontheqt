{# One rating badge in the show hero's metadata line (script-plex-seasons; Plezy InlineRatingBadges): the source's
   icon, sized by source so narrow icons don't leave gaps, then the bold score. Shown for the show only (not while a
   season fills the hero). params: prop (window property with the score), image (property with the icon path) #}
<control type="image">
    <visible>String.IsEmpty(Window.Property(hero.line)) + !String.IsEmpty(Window.Property({{ prop }})) + String.Contains(Window.Property({{ image }}),imdb)</visible>
    <posy>{{ vscale(3) }}</posy>
    <width>63</width>
    <height>{{ vscale(30) }}</height>
    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Window.Property({{ image }})]</texture>
    <aspectratio align="left">keep</aspectratio>
</control>
<control type="image">
    <visible>String.IsEmpty(Window.Property(hero.line)) + !String.IsEmpty(Window.Property({{ prop }})) + String.Contains(Window.Property({{ image }}),spilled)</visible>
    <posy>{{ vscale(3) }}</posy>
    <width>40</width>
    <height>{{ vscale(30) }}</height>
    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Window.Property({{ image }})]</texture>
    <aspectratio align="left">keep</aspectratio>
</control>
<control type="image">
    <visible>String.IsEmpty(Window.Property(hero.line)) + !String.IsEmpty(Window.Property({{ prop }})) + !String.Contains(Window.Property({{ image }}),imdb) + !String.Contains(Window.Property({{ image }}),spilled)</visible>
    <posy>{{ vscale(3) }}</posy>
    <width>32</width>
    <height>{{ vscale(30) }}</height>
    <texture fallback="script.plex/ratings/other/image.rating.png">$INFO[Window.Property({{ image }})]</texture>
    <aspectratio align="left">keep</aspectratio>
</control>
<control type="image">
    <visible>String.IsEmpty(Window.Property(hero.line)) + !String.IsEmpty(Window.Property({{ prop }}))</visible>
    <width>6</width>
    <height>{{ vscale(36) }}</height>
    <texture>-</texture>
</control>
<control type="label">
    <visible>String.IsEmpty(Window.Property(hero.line)) + !String.IsEmpty(Window.Property({{ prop }}))</visible>
    <width>auto</width>
    <height>{{ vscale(36) }}</height>
    <font>font13</font>
    <aligny>center</aligny>
    <textcolor>{{ core.plezy.text }}</textcolor>
    <shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
    <label>[B]$INFO[Window.Property({{ prop }})][/B]</label>
</control>
<control type="image">
    <visible>String.IsEmpty(Window.Property(hero.line)) + !String.IsEmpty(Window.Property({{ prop }}))</visible>
    <width>18</width>
    <height>{{ vscale(36) }}</height>
    <texture>-</texture>
</control>

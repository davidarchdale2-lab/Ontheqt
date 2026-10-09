{# Plezy spotlight scrims (tv_spotlight_background.dart): bg fade behind the left text column, black at the top,
   bg into the bottom rows. Pair with default_background.xml.tpl "with spotlight=True" (no flat dim).
   foot=True: on non-16:9 displays vscale(1080) is shorter than the window, so the backdrop would show unscrimmed
   below the layout; carry scrim-v's bg foot on down instead. Leave it off where video plays behind the scrims. #}
<control type="image">
    <posx>0</posx><posy>0</posy><width>1920</width><height>{{ vscale(1080) }}</height>
    <texture>script.plex/plezy/scrim-h.png</texture>
</control>
<control type="image">
    <posx>0</posx><posy>0</posy><width>1920</width><height>{{ vscale(1080) }}</height>
    <texture>script.plex/plezy/scrim-v.png</texture>
</control>
{% if foot and core.needs_scaling %}
<control type="image">
    <posx>0</posx>
    <posy>{{ vscale(1080) }}</posy>
    <width>1920</width>
    <height>1080</height>
    <texture colordiffuse="{{ core.plezy.bg }}">script.plex/white-square.png</texture>
</control>
{% endif %}

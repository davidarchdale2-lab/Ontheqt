{# Plezy spotlight scrims (tv_spotlight_background.dart): bg fade behind the left text column, black at the top,
   bg into the bottom rows. Pair with default_background.xml.tpl "with spotlight=True" (no flat dim). #}
<control type="image">
    <posx>0</posx><posy>0</posy><width>1920</width><height>{{ vscale(1080) }}</height>
    <texture>script.plex/plezy/scrim-h.png</texture>
</control>
<control type="image">
    <posx>0</posx><posy>0</posy><width>1920</width><height>{{ vscale(1080) }}</height>
    <texture>script.plex/plezy/scrim-v.png</texture>
</control>

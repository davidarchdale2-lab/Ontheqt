{# Plezy StateMessageWidget (lib/screens/libraries/state_messages.dart): a centred 120px icon at 40% (faint), a muted
   title and the body text under it. The block is centred horizontally in the box x..x+w, with the icon's top at y.
   params: icon (texture), title, subtitle (optional), x, y, w (box), visible (condition) #}
<control type="group">
    <visible>{{ visible }}</visible>
    <control type="image">
        <posx>{{ x + (w - 120) / 2 }}</posx>
        <posy>{{ y|vscale }}</posy>
        <width>120</width>
        <height>{{ vscale(120) }}</height>
        <texture colordiffuse="{{ core.plezy.faint }}">{{ icon }}</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <posx>{{ x }}</posx>
        <posy>{{ (y + 144)|vscale }}</posy>
        <width>{{ w }}</width>
        <height>{{ vscale(48) }}</height>
        <font>font14</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.muted }}</textcolor>
        <label>{{ title }}</label>
    </control>
    {% if subtitle %}
    <control type="label">
        <posx>{{ x }}</posx>
        <posy>{{ (y + 196)|vscale }}</posy>
        <width>{{ w }}</width>
        <height>{{ vscale(40) }}</height>
        <font>font12</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>{{ subtitle }}</label>
    </control>
    {% endif %}
</control>

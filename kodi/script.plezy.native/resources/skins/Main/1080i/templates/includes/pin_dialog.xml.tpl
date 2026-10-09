{# Plezy PinEntryDialog, TV variant (edde746/plezy lib/screens/profile/pin_entry_dialog.dart) at x1.5, as group 400 of
   script-plex-user_select.xml.tpl: a 480px card (radius 28) with the profile name and a lock, four digit boxes and a 3x4 keypad
   [1 2 3][4 5 6][7 8 9][close 0 backspace]. The selected key is a white (text) rounded square with an on_primary glyph; the others
   are surface on surface, so they read as unboxed, exactly as in Plezy. The 4th digit submits (lib/windows/userselect.py).
   Buttons 201-209 are the digits, 210 is 0, 211 backspace and 212 close (skin-only: it just moves focus back to the list).
   Navigation is clamped (Plezy's keypad cursor does not wrap or leave); every key names its own id on the edges.
   Digit boxes follow the row item's Property(pin.len) (0-4): the active box is the next one to fill (clamped to the 4th), filled boxes
   show a bullet, empty ones a dash. The card closes while the profile is being switched (Window.Property(switching), the overlay takes
   over) and re-opens if the PIN was wrong: a wrong PIN sets Window.Property(pin.error), the card grows to hold the message and shakes
   (+-10lp x1.5 over 600ms, five 120ms legs) every time the property goes from empty to set. #}
<control type="group" id="400">
    <defaultcontrol always="true">201</defaultcontrol>
    <visible allowhiddenfocus="true">!String.IsEmpty(Container(101).ListItem.Property(protected)) + ControlGroup(400).HasFocus(0) + !String.IsEmpty(Window.Property(initialized)) + String.IsEmpty(Window.Property(switching))</visible>
    <animation type="Visible" reversible="false">
        <effect type="fade" start="0" end="100" time="150" tween="cubic" easing="out" />
        <effect type="zoom" start="95" end="100" time="150" center="auto" tween="cubic" easing="out" />
    </animation>
    <animation type="Conditional" condition="!String.IsEmpty(Window.Property(pin.error))" reversible="false">
        <effect type="slide" end="15,0" time="120" tween="sine" easing="inout" />
        <effect type="slide" end="-30,0" delay="120" time="120" tween="sine" easing="inout" />
        <effect type="slide" end="30,0" delay="240" time="120" tween="sine" easing="inout" />
        <effect type="slide" end="-30,0" delay="360" time="120" tween="sine" easing="inout" />
        <effect type="slide" end="15,0" delay="480" time="120" tween="sine" easing="inout" />
    </animation>
    <posx>720</posx>
    <posy>{{ vperc(vscale(594)) }}</posy>

    {# card: 594 tall, 672 once the error line is shown #}
    <control type="image">
        <visible>String.IsEmpty(Window.Property(pin.error))</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>480</width>
        <height>{{ vscale(594) }}</height>
        <texture border="28" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r28.png</texture>
    </control>
    <control type="image">
        <visible>!String.IsEmpty(Window.Property(pin.error))</visible>
        <posx>0</posx>
        <posy>0</posy>
        <width>480</width>
        <height>{{ vscale(672) }}</height>
        <texture border="28" colordiffuse="{{ core.plezy.surface }}">script.plex/plezy/r28.png</texture>
    </control>

    {# title row: lock + the profile's name #}
    <control type="image">
        <posx>21</posx>
        <posy>{{ vscale(21) }}</posy>
        <width>36</width>
        <height>{{ vscale(36) }}</height>
        <texture colordiffuse="{{ core.plezy.text }}">script.plex/plezy/icons/lock.png</texture>
        <aspectratio>keep</aspectratio>
    </control>
    <control type="label">
        <posx>75</posx>
        <posy>{{ vscale(18) }}</posy>
        <width>384</width>
        <height>{{ vscale(42) }}</height>
        <font>font12</font>
        <align>left</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>$INFO[Container(101).ListItem.Label]</label>
    </control>

    {# four digit boxes, 72 x 84, gap 15 #}
    {% for i in range(4) %}
    {% with bx = 74 + i * 87 & i1 = i + 1 %}
    {# inactive: a 2px outline (Plezy: outlineVariant, which the mono scheme resolves to onSurface) #}
    <control type="image">
        <visible>!{% if i == 0 %}[String.IsEqual(Container(101).ListItem.Property(pin.len),0) | String.IsEmpty(Container(101).ListItem.Property(pin.len))]{% elif i == 3 %}[String.IsEqual(Container(101).ListItem.Property(pin.len),3) | String.IsEqual(Container(101).ListItem.Property(pin.len),4)]{% else %}String.IsEqual(Container(101).ListItem.Property(pin.len),{{ i }}){% endif %}</visible>
        <posx>{{ bx }}</posx>
        <posy>{{ vscale(75) }}</posy>
        <width>72</width>
        <height>{{ vscale(84) }}</height>
        <texture border="8" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/outline-r8.png</texture>
    </control>
    {# active: primary @ 8% fill and the 2.5lp primary border (3px, drawn outside the box) #}
    <control type="group">
        <visible>{% if i == 0 %}[String.IsEqual(Container(101).ListItem.Property(pin.len),0) | String.IsEmpty(Container(101).ListItem.Property(pin.len))]{% elif i == 3 %}[String.IsEqual(Container(101).ListItem.Property(pin.len),3) | String.IsEqual(Container(101).ListItem.Property(pin.len),4)]{% else %}String.IsEqual(Container(101).ListItem.Property(pin.len),{{ i }}){% endif %}</visible>
        <control type="image">
            <posx>{{ bx }}</posx>
            <posy>{{ vscale(75) }}</posy>
            <width>72</width>
            <height>{{ vscale(84) }}</height>
            <texture border="8" colordiffuse="{{ core.plezy.input_fill }}">script.plex/plezy/r8.png</texture>
        </control>
        <control type="image">
            <posx>{{ bx - 3 }}</posx>
            <posy>{{ vscale(72) }}</posy>
            <width>78</width>
            <height>{{ vscale(90) }}</height>
            <texture border="11" colordiffuse="{{ core.plezy.text }}">script.plex/plezy/ring-8.png</texture>
        </control>
    </control>
    {# the digit: a bullet once entered, a faint dash while empty #}
    <control type="label">
        <visible>{% for k in range(i1, 5) %}String.IsEqual(Container(101).ListItem.Property(pin.len),{{ k }}){% if not loop.is_last %} | {% endif %}{% endfor %}</visible>
        <posx>{{ bx }}</posx>
        <posy>{{ vscale(75) }}</posy>
        <width>72</width>
        <height>{{ vscale(84) }}</height>
        <font>font20_title</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.text }}</textcolor>
        <label>&#8226;</label>
    </control>
    <control type="label">
        <visible>!{% if i == 3 %}String.IsEqual(Container(101).ListItem.Property(pin.len),4){% else %}[{% for k in range(i1, 5) %}String.IsEqual(Container(101).ListItem.Property(pin.len),{{ k }}){% if not loop.is_last %} | {% endif %}{% endfor %}]{% endif %}</visible>
        <posx>{{ bx }}</posx>
        <posy>{{ vscale(75) }}</posy>
        <width>72</width>
        <height>{{ vscale(84) }}</height>
        <font>font20_title</font>
        <align>center</align>
        <aligny>center</aligny>
        <scroll>false</scroll>
        <textcolor>{{ core.plezy.faint }}</textcolor>
        <label>&#8211;</label>
    </control>
    {% endwith %}
    {% endfor %}

    {# keypad: 90px keys, gap 9, from (96, 186). id, column, row, up, down, left, right, digit, icon (close / backspace) #}
    <control type="group" id="300">
        <defaultcontrol>201</defaultcontrol>
        <control type="group" id="200">
            <defaultcontrol>201</defaultcontrol>
            {% for kid, col, row, up, down, left, right, num, icon in [[201, 0, 0, 201, 204, 201, 202, "1", ""], [202, 1, 0, 202, 205, 201, 203, "2", ""], [203, 2, 0, 203, 206, 202, 203, "3", ""], [204, 0, 1, 201, 207, 204, 205, "4", ""], [205, 1, 1, 202, 208, 204, 206, "5", ""], [206, 2, 1, 203, 209, 205, 206, "6", ""], [207, 0, 2, 204, 212, 207, 208, "7", ""], [208, 1, 2, 205, 210, 207, 209, "8", ""], [209, 2, 2, 206, 211, 208, 209, "9", ""]] %}
            {% include "includes/pin_key.xml.tpl" %}
            {% endfor %}
        </control>
        {% for kid, col, row, up, down, left, right, num, icon in [[212, 0, 3, 207, 212, 212, 210, "", "close"], [210, 1, 3, 208, 210, 212, 211, "0", ""], [211, 2, 3, 209, 211, 210, 211, "", "backspace"]] %}
        {% include "includes/pin_key.xml.tpl" %}
        {% endfor %}
    </control>

    {# a wrong PIN: the message sits under the keypad (the card is 78 taller) #}
    <control type="label">
        <visible>!String.IsEmpty(Window.Property(pin.error))</visible>
        <posx>21</posx>
        <posy>{{ vscale(591) }}</posy>
        <width>438</width>
        <height>{{ vscale(60) }}</height>
        <font>font10</font>
        <align>left</align>
        <aligny>top</aligny>
        <textcolor>{{ core.plezy.error }}</textcolor>
        <label>$INFO[Window.Property(pin.error)]</label>
    </control>
</control>

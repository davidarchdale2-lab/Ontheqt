{% extends "base.xml.tpl" %}
{# Screensaver slideshow. Plezy has no counterpart, so the clock and title use its spotlight text idiom (see
   PLEZY_DESIGN.md): the clock in bold 45, the image title under it in the summary colour, both on the shadow colour.
   Python (lib/windows/slidehshow.py Slideshow) relies on: 1 (the image), 100 (info group: it reads its position and
   height and mirrors it vertically every minute: newY = 1080 - y - h, so its top margin (64) and bottom margin (1080 -
   64 - 120 = 896) are symmetric), 101 / 105 (clock / title, left aligned), 111 / 115 (right aligned). #}
{% block headers %}<zorder>6</zorder>{% endblock %}
{% block backgroundcolor %}{% endblock %}
{% block coordinates %}{% endblock %}
{% block controls %}
<control type="group">
	<control type="image" id="1">
		<posx>0</posx>
		<posy>0</posy>
		<width>1920</width>
		<height>1080</height>
		<texture background="true"></texture>
		<aspectratio>keep</aspectratio>
		<fadetime>1000</fadetime>
		<texture>$INFO[Window.Property(thumb)]</texture>
	</control>
	<control type="group" id="100">
		<posx>96</posx>
		<posy>{{ vscale(64) }}</posy>
		<height>{{ vscale(120) }}</height>
		<width>1728</width>
		<control type="label" id="101">
			<visible>String.IsEqual(Window.Property(align),0)</visible>
			<posx>0</posx>
			<posy>0</posy>
			<width>1728</width>
			<height>{{ vscale(64) }}</height>
			<font>font45</font>
			<align>left</align>
			<aligny>center</aligny>
			<scroll>false</scroll>
			<textcolor>{{ core.plezy.text }}</textcolor>
			<shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
			<label>[B]$INFO[Window.Property(clock)][/B]</label>
		</control>
		<control type="label" id="105">
			<visible>String.IsEqual(Window.Property(align),0)</visible>
			<posx>0</posx>
			<posy>{{ vscale(68) }}</posy>
			<width>1728</width>
			<height>{{ vscale(40) }}</height>
			<font>font12</font>
			<align>left</align>
			<aligny>center</aligny>
			<scroll>false</scroll>
			<textcolor>{{ core.plezy.summary }}</textcolor>
			<shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
			<label>$INFO[Window.Property(title)]</label>
		</control>
		<control type="label" id="111">
			<visible>String.IsEqual(Window.Property(align),1)</visible>
			<posx>0</posx>
			<posy>0</posy>
			<width>1728</width>
			<height>{{ vscale(64) }}</height>
			<font>font45</font>
			<align>right</align>
			<aligny>center</aligny>
			<scroll>false</scroll>
			<textcolor>{{ core.plezy.text }}</textcolor>
			<shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
			<label>[B]$INFO[Window.Property(clock)][/B]</label>
		</control>
		<control type="label" id="115">
			<visible>String.IsEqual(Window.Property(align),1)</visible>
			<posx>0</posx>
			<posy>{{ vscale(68) }}</posy>
			<width>1728</width>
			<height>{{ vscale(40) }}</height>
			<font>font12</font>
			<align>right</align>
			<aligny>center</aligny>
			<scroll>false</scroll>
			<textcolor>{{ core.plezy.summary }}</textcolor>
			<shadowcolor>{{ core.plezy.shadow }}</shadowcolor>
			<label>$INFO[Window.Property(title)]</label>
		</control>
	</control>
</control>
{% endblock controls %}

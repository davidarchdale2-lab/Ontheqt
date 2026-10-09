{% extends "base.xml.tpl" %}
{# Plezy loading indicator (edde746/plezy lib/utils/dialogs.dart showLoadingDialog, loading_indicator_box.dart): a bare
   circular progress indicator in the middle of the screen, no card. Kodi has no indeterminate arc, so includes/plezy_spinner
   rotates a 270 degree arc once a second. No controls: the Python only shows and closes the window. #}
{% block backgroundcolor %}{% endblock %}
{% block controls %}
<control type="group">
    <animation effect="fade" start="0" end="100" time="160" tween="cubic" easing="out">WindowOpen</animation>
    <animation effect="fade" start="100" end="0" time="120" tween="cubic" easing="in">WindowClose</animation>
    <posx>0</posx>
    <posy>{{ vperc(vscale(60)) }}</posy>
    {% include "includes/plezy_spinner.xml.tpl" with x = 930 & y = 0 & size = 60 %}
</control>
{% endblock controls %}

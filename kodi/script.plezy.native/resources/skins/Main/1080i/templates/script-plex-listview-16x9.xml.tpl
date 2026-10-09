{% extends "library_posters.xml.tpl" %}
{# Plezy library list view (16x9 rows): the library header, filter row and play / shuffle / view-type buttons are the
   grids' (library_posters.xml.tpl); the content is a full-width list (includes/library_list_view.xml.tpl). The header
   and the filter row stay in place while the list scrolls under them. #}
{% block header_bg %}{% endblock %}
{% block header_animation %}{% endblock %}
{# never hide or slide the filter row away (the grids do after their sixth item) #}
{% block hide_filter_from_index %}100000{% endblock %}

{% block content %}
{% include "includes/library_list_view.xml.tpl" with square=False %}
{% endblock content %}

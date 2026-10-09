# coding=utf-8

TEMPLATE_CONTEXTS = {
    "core": {
        "resolution": (1920, 1080),
        "needs_scaling": False,
        "hub_count": 8,  # Default number of hub rows on home screen
        "search_hub_count": 12,  # Fixed search result rows; must match SearchDialog.SEARCH_HUB_COUNT
        # Plezy design tokens (edde746/plezy lib/theme/mono_theme.dart, dark), as Kodi AARRGGBB
        "plezy": {
            "bg": "FF0E0F12",
            "surface": "FF15171C",
            "text": "FFEDEDED",
            "muted": "99EDEDED",         # textMuted: text @ 60%
            "subtle": "8AEDEDED",        # inactive hub title @ 54%
            "summary": "C7EDEDED",       # spotlight summary @ 78%
            "outline": "1FFFFFFF",
            "focus_fill": "1FEDEDED",    # focused tile/rail item @ 12%
            "selected_fill": "1AEDEDED", # selected rail item @ 10%
            "selected_focus_fill": "26EDEDED",  # focused + selected @ 15%
            "track": "33EDEDED",         # inactive progress track
            "scrim": "66000000",         # modal rail scrim over content
            "on_primary": "FF0E0F12",    # text on white pill buttons
            "faint": "66EDEDED",         # empty-state icons, placeholders @ 40%
            "disabled": "61EDEDED",      # disabled text @ 38%
            "tonal": "6115171C",         # idle filled-tonal action / chip (surface @ 38%)
            "tile": "6B15171C",          # idle rail action card (surface @ 42%)
            "focus_bg": "33FFFFFF",      # FocusTheme.focusBackgroundDecoration (white @ 20%)
            "menu_surface": "FF26282D",  # menus and popups (surfaceContainer)
            "input_fill": "14EDEDED",    # text field fill
            "input_focus_fill": "2EEDEDED",
            "chip_selected_focus": "FFB7B8B9",
            "chrome_idle": "4D000000",   # round chrome buttons over artwork (back/home/search)
            "chrome_focus": "80000000",
            "shadow": "CC0E0F12",        # text shadow over artwork
            "dialog_scrim": "8A000000",  # behind dialogs (black54)
            "sheet_scrim": "80000000",   # behind bottom sheets / player barrier
            "error": "FFB00020",
            # player chrome (always white on video, independent of the theme)
            "player_fg": "FFFFFFFF",
            "player_fg_muted": "B3FFFFFF",
            "player_fg_subtle": "99FFFFFF",
            "player_track": "4DFFFFFF",
            "player_buffer": "80FFFFFF",
            "player_card": "CC000000",
            "player_tooltip": "99000000",
            "player_skip": "E6FFFFFF",   # skip-marker button fill (white 90%)
            "active": "FFFFC107",        # active player toggles (Plezy's amber)
            # TV layout (1080p)
            "rail_collapsed": 72,
            "rail_expanded": 300,
            "content_left": 120,
        },
    },
    "indicators": {
        "base": {
            "use_scaling": False,
            "show": True,
            "scale": {

            }
        },
        "none": {
            "INHERIT": "base",
            "use_unwatched": True,
            "show": False
        },
        "classic": {
            "INHERIT": "base",
            "use_unwatched": True,
            "hide_aw_bg": None,
            "watched_bg": None,
            "unwatched_count_bg": "FFCC7B19",
            "textcolor": "FF000000",
            "assets": {
                "unwatched": "unwatched.png"
            }
        },
        "modern": {
            "INHERIT": "base",
            "use_scaling": True,
            "scale": {
                "tiny": 0.75,
                "small": 1.0,
                "medium": 1.175,
                "large": 1.3
            },
            "use_unwatched": False,
            "hide_aw_bg": False,
            "watched_bg": "CC000000",
            "unwatched_count_bg": "CC000000",
            "textcolor": "FFFFFFFF",
            "assets": {
                "watched": "watched.png"
            }
        },
        "modern_2024": {
            "INHERIT": "modern",
            "assets": {
                "watched": "watched_2024.png"
            }
        }
    },
    "themes": {
        "base": {
            # general config
            "assets": {
                "buttons": {
                    "base": "script.plex/buttons/",
                    "focusSuffix": "-focus",
                }
            },
            "buttons": {
                "useFocusColor": True,
                "useNoFocusColor": True,
                "zoomPlayButton": False,
                "focusColor": None,
                "noFocusColor": None
            },

            # specific interface config
            "episodes": {
                "use_button_bg": False,
                "button_bg_color": None,
                "buttongroup": {
                    "posy": None,
                    "itemgap": -50,
                },
                # this button group will only exist when multiple media files for an episode exist, it adds another button
                "buttongroup_1300": {
                    "posy": None,
                    "itemgap": -50,
                },
                # applies to the main buttons
                "buttons": {
                    "width": None,
                    "height": None,
                }
            },
            "seasons": {
                "buttongroup": {
                    "itemgap": -20
                },
                "buttons": {
                    "width": None,
                    "height": None,
                }
            },
            "pre_play": {
                "buttongroup": {
                    "itemgap": -20
                },
                "buttons": {
                    "width": None,
                    "height": None,
                }
            }
        },
        "classic": {
            "INHERIT": "base",
            "episodes": {
                "buttongroup": {
                    "posy": 369
                },
                "buttongroup_1300": {
                    "posy": 388.5  # a number: vscale multiplies it on non-16:9 displays
                },
                "buttons": {
                    "width": 176,
                    "height": 140
                },
                "buttons_1300": {
                    "width": 161,
                    "height": 125
                }
            },
            "seasons": {
                "buttons": {
                    "width": 126,
                    "height": 100,
                }
            },
            "pre_play": {
                "buttongroup": {
                    "itemgap": -50
                },
                "buttons": {
                    "width": 176,
                    "height": 140,
                }
            },
        },
        "modern": {
            "INHERIT": "base",
            "assets": {
                "buttons": {
                    "base": "script.plex/buttons/player/modern/",
                    "focusSuffix": "",
                }
            },
            "buttons": {
                "useFocusColor": False,
                "zoomPlayButton": True,
                "noFocusColor": "88FFFFFF"
            },
            "episodes": {
                "use_button_bg": True,
                "button_bg_color": "66000000",
                "buttongroup": {
                    "posy": 369,
                    "itemgap": -40,
                },
                "buttongroup_1300": {
                    "posy": 369,
                    "itemgap": -40,
                },
                "buttons": {
                    "width": 131,
                    "height": 104,
                },
                "buttons_1300": {
                    "width": 131,
                    "height": 104
                }
            },
            "seasons": {
                "buttongroup": {
                    "itemgap": -40
                },
                "buttons": {
                    "width": 152,
                    "height": 121,
                }
            },
            "pre_play": {
                "buttongroup": {
                    "itemgap": -40
                },
                "buttons": {
                    "width": 152,
                    "height": 121,
                }
            }
        },
        # Plezy's round controls: muted glyphs that turn into a white disc with the glyph cut out on focus
        "plezy": {
            "INHERIT": "modern",
            "assets": {
                "buttons": {
                    "base": "script.plex/buttons/player/plezy/",
                    "focusSuffix": "-focus",
                }
            },
            "buttons": {
                "useFocusColor": False,
                "zoomPlayButton": False,
                "noFocusColor": "B3EDEDED"
            },
        },
        "modern-colored": {
            "INHERIT": "modern",
            "buttons": {
                "useFocusColor": True,
                "zoomPlayButton": False,
            }
        },
        "modern-dotted": {
            "INHERIT": "modern",
            "assets": {
                "buttons": {
                    "base": "script.plex/buttons/player/modern-dotted/",
                    "focusSuffix": "-focus",
                }
            },
            "buttons": {
                "useFocusColor": False,
                "zoomPlayButton": False,
            }
        }
    }
}

# coding=utf-8

from kodi_six import xbmc, xbmcgui

def _getGlobalProperty(key, base='script.plezy.native.{0}'):
    return xbmc.getInfoLabel('Window(10000).Property({0})'.format(base.format(key)))

def _setGlobalProperty(key, val, base='script.plezy.native.{0}'):
    xbmcgui.Window(10000).setProperty(base.format(key), val)

def _setGlobalBoolProperty(key, boolean, base='script.plezy.native.{0}'):
    xbmcgui.Window(10000).setProperty(base.format(key), boolean and '1' or '')

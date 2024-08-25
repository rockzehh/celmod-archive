#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "zaachhhh"
#define PLUGIN_VERSION "1.00.1"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "|CelMod| Weapons",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = "https://bitbucket.org/zaachhhh/celmod"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_sunflower", Command_DeathStick, "Enables/Disables the sunflower.");
}

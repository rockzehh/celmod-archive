#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "FusionLock"
#define PLUGIN_VERSION "1.01.1"

#include <sourcemod>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "|CelMod| - Web Shortcuts",
	author = PLUGIN_AUTHOR,
	description = "Creates commands to open up certain webpages.",
	version = PLUGIN_VERSION,
	url = "http://xfusionlockx.tk/celmod"
};

public void OnPluginStart()
{
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
}

public Action Command_Say(int iClient, const char[] sCommand, int iArgs)
{
	char sCmd[256];
	
	GetCmdArg(1, sCmd, sizeof(sCmd));
	
	StripQuotes(sCmd);
	
	if (StrEqual(sCmd, "!colorlist") || StrEqual(sCmd, "!colors"))
	{
		CM_ShowCelModViewer(iClient, "http://www.xfusionlockx.xyz/celmod/colors.html");
		return Plugin_Handled;
	}else if (StrEqual(sCmd, "!commandslist") || StrEqual(sCmd, "!cmds"))
	{
		CM_ShowCelModViewer(iClient, "http://www.xfusionlockx.xyz/celmod/cmds.html");
		return Plugin_Handled;
	}else if (StrEqual(sCmd, "!musiclist"))
	{
		CM_ShowCelModViewer(iClient, "http://www.xfusionlockx.xyz/celmod/music.html");
		return Plugin_Handled;
	}else if (StrEqual(sCmd, "!proplist") || StrEqual(sCmd, "!props"))
	{
		CM_ShowCelModViewer(iClient, "http://www.xfusionlockx.xyz/celmod/props.html");
		return Plugin_Handled;
	}else if (StrEqual(sCmd, "!soundlist") || StrEqual(sCmd, "!sounds"))
	{
		CM_ShowCelModViewer(iClient, "http://www.xfusionlockx.xyz/celmod/sounds.html");
		return Plugin_Handled;
	}else if (StrEqual(sCmd, "!updates"))
	{
		CM_ShowCelModViewer(iClient, "http://www.xfusionlockx.xyz/celmod/updates.html");
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public void CM_ShowCelModViewer(int iClient, char[] sURL)
{
	ShowMOTDPanel(iClient, "|CelMod| Viewer", sURL, MOTDPANEL_TYPE_URL);
}

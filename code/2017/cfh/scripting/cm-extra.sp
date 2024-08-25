#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <celmod>

#pragma newdecls required

#define VERSION "1.1.0"

public Plugin myinfo = 
{
	name = "|CelMod| Client Extras", 
	author = "FusionLock", 
	description = "Extra Client Bullshit.", 
	version = VERSION, 
	url = "https://bitbucket.org/zaachhhh/celmod-cels-fun-house"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_firstperson", Command_FirstPerson, "Enables firstperson.");
	RegConsoleCmd("sm_thirdperson", Command_ThirdPerson, "Enables thirdperson.");
}

public Action Command_FirstPerson(int iClient, int iArgs)
{
	CelMod_ThirdPerson(iClient, false);
	
	CelMod_ReplyToCommand(iClient, "Enabled firstperson mode.");
	
	return Plugin_Handled;
}

public Action Command_ThirdPerson(int iClient, int iArgs)
{
	CelMod_ThirdPerson(iClient, true);
	
	CelMod_ReplyToCommand(iClient, "Enabled thirdperson mode.");
	
	return Plugin_Handled;
}

//Plugin Stocks:
void CelMod_ThirdPerson(int iClient, bool bThirdPerson)
{
	if (bThirdPerson)
	{
		SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", 0);
		SetEntProp(iClient, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(iClient, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(iClient, Prop_Send, "m_iFOV", 120);
	} else {
		SetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget", iClient);
		SetEntProp(iClient, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(iClient, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(iClient, Prop_Send, "m_iFOV", 90);
	}
} 
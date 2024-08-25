#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "zaachhhh"
#define PLUGIN_VERSION "1.00.1"

#include <sourcemod>
#include <sdktools>
#include <morecolors>
#include <s-a-s>

#pragma newdecls required

ConVar g_cvSkyBox;

public Plugin myinfo = 
{
	name = "|CelMod| Skyboxes",
	author = PLUGIN_AUTHOR,
	description = "Anything having to do with skyboxes",
	version = PLUGIN_VERSION,
	url = "https://bitbucket.org/zaachhhh/celmod"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_skybox", Command_SkyBox, "Changes the skybox on the map.");
	
	g_cvSkyBox = FindConVar("sv_skyname");
}

public Action Command_SkyBox(int iClient, int iArgs)
{
	if (SAS_CheckAdmin(iClient))
	{
		if (SAS_CheckAdminLevel(iClient, 3))
		{
			Menu mSkyBox = new Menu(Menu_SkyBox, MENU_ACTIONS_ALL);
	
			mSkyBox.SetTitle("SkyBox List");
			
			mSkyBox.AddItem("sky_borealis01", "sky_borealis01");
			mSkyBox.AddItem("sky_day01_01", "sky_day01_01");
			mSkyBox.AddItem("sky_day01_04", "sky_day01_04");
			mSkyBox.AddItem("sky_day01_05", "sky_day01_05");
			mSkyBox.AddItem("sky_day01_06", "sky_day01_06");
			mSkyBox.AddItem("sky_day01_07", "sky_day01_07");
			mSkyBox.AddItem("sky_day01_08", "sky_day01_08");
			mSkyBox.AddItem("sky_day01_09", "sky_day01_09");
			mSkyBox.AddItem("sky_day02_01", "sky_day02_01");
			mSkyBox.AddItem("sky_day02_02", "sky_day02_02");
			mSkyBox.AddItem("sky_day02_03", "sky_day02_03");
			mSkyBox.AddItem("sky_day02_04", "sky_day02_04");
			mSkyBox.AddItem("sky_day02_05", "sky_day02_05");
			mSkyBox.AddItem("sky_day02_06", "sky_day02_06");
			mSkyBox.AddItem("sky_day02_07", "sky_day02_07");
			mSkyBox.AddItem("sky_day02_09", "sky_day02_09");
			mSkyBox.AddItem("sky_day02_10", "sky_day02_10");
			mSkyBox.AddItem("sky_day03_01", "sky_day03_01");
			mSkyBox.AddItem("sky_day03_02", "sky_day03_02");
			mSkyBox.AddItem("sky_day03_03", "sky_day03_03");
			mSkyBox.AddItem("sky_day03_04", "sky_day03_04");
			mSkyBox.AddItem("sky_day03_05", "sky_day03_05");
			mSkyBox.AddItem("sky_day03_06", "sky_day03_06");
			mSkyBox.AddItem("sky_wasteland02", "sky_wasteland02");
			
			mSkyBox.ExitButton = true;
			
			mSkyBox.Display(iClient, MENU_TIME_FOREVER);
			
			return Plugin_Handled;
		} else {
			CReplyToCommand(iClient, "{blue}|CelMod|{default} You do not have high enough admin privileges!");
			return Plugin_Handled;
		}
	} else {
		CReplyToCommand(iClient, "{blue}|CelMod|{default} You do not have access to that command!");
		return Plugin_Handled;
	}
}

public int Menu_SkyBox(Menu mMenu, MenuAction maAction, int iParam1, int iParam2)
{
	switch (maAction)
	{
		case MenuAction_Display:
		{
			Panel pPanel = view_as<Panel>(iParam2);
			
			pPanel.SetTitle("SkyBox List");
		}
		
		case MenuAction_Select:
		{
			char sInfo[128];
			
			mMenu.GetItem(iParam2, sInfo, sizeof(sInfo));
			
			SetConVarString(g_cvSkyBox, sInfo);
			
			for (int i = 1; i < GetMaxClients(); i++)
			{
				if(IsClientConnected(i))
				{
					CreateDataTimer(5.0, TIMER_HNDL_CLOSE, Timer_ReconnectClient);
				}
			}
		}
		
		case MenuAction_End:
		{
			delete mMenu;
		}
		
		case MenuAction_DrawItem:
		{
			int iStyle;
			
			char sInfo[32];
			
			mMenu.GetItem(iParam2, sInfo, sizeof(sInfo), iStyle);
			
			return iStyle;
		}
	}
	return 0;
}

public Action Timer_ReconnectClient()

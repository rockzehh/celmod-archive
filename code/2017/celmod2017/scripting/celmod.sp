#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "zaachhhh"
#define PLUGIN_VERSION "1.10.3"

#include <sourcemod>
#include <sdktools>
#include <morecolors>
#include <s-a-s>
//#include <soundlib>

#pragma newdecls required

#define MAXENTITIES 2048

bool g_bCMEntity[MAXENTITIES + 1] = false;
bool g_bCanCopy[MAXENTITIES + 1] = false;
bool g_bConnected[MAXPLAYERS + 1] = false;
bool g_bCopyQueue[MAXPLAYERS + 1] = false;
bool g_bFadeColor[MAXENTITIES + 1] = false;
bool g_bGettingPositions[MAXPLAYERS + 1] = false;
bool g_bGodMode[MAXPLAYERS + 1] = false;
bool g_bIsInLand[MAXPLAYERS + 1] = false;
bool g_bLandDrawing[MAXPLAYERS + 1] = false;
bool g_bSentMessage[MAXPLAYERS + 1] = false;
bool g_bSolid[MAXENTITIES + 1] = true;
bool g_bStartedLand[MAXPLAYERS + 1] = false;
bool g_bLoop[MAXENTITIES + 1] = false;
bool g_bPlaying[MAXENTITIES + 1] = false;
bool g_bButtonUse[MAXPLAYERS + 1] = false;

char g_sAreaDB[PLATFORM_MAX_PATH];
char g_sAuthID[MAXPLAYERS + 1][64];
char g_sCopyInformation[MAXPLAYERS + 1][8][128];
char g_sInternetURL[MAXENTITIES + 1][256];
char g_sPropName[MAXENTITIES + 1][64];
char g_sColorDB[PLATFORM_MAX_PATH];
char g_sDownloadDB[PLATFORM_MAX_PATH];
char g_sSound[MAXENTITIES + 1][128];
char g_sMusic[MAXENTITIES + 1][128];
char g_sBalanceDB[PLATFORM_MAX_PATH];
char g_sSoundDB[PLATFORM_MAX_PATH];
char g_sSpawnDB[PLATFORM_MAX_PATH];
char g_sSoundModel[128];
char g_sMusicModel[128];

ConVar g_hCelLimit;
ConVar g_hPropLimit;

float g_fCopyOrigin[MAXPLAYERS + 1][3];
float g_fFadeColor[MAXENTITIES + 1][4];
float g_fFadeColors[MAXENTITIES + 1][2][4];
float g_fGrabOrigin[MAXPLAYERS + 1][3];
float g_fLandGravity[MAXPLAYERS + 1];
float g_fLandOrigin[MAXPLAYERS + 1][2][3];
float g_fZero[3] =  { 0.0, 0.0, 0.0 };
float g_fMusicTime[MAXENTITIES + 1];
float g_fEntityTime[MAXPLAYERS + 1] = 0.0;

int g_iBeam;
int g_iCelCount[MAXPLAYERS + 1];
int g_iCelLimit;
int g_iColor[MAXENTITIES + 1][4];
int g_iEntityDissolver;
int g_iEntityIgniter;
int g_iHalo;
int g_iCopyEnt[MAXPLAYERS + 1];
int g_iGrabEnt[MAXPLAYERS + 1];
int g_iLand;
int g_iOwner[MAXENTITIES + 1];
int g_iPhys;
int g_iPropCount[MAXPLAYERS + 1];
int g_iPropLimit;
int g_iClientColor[MAXPLAYERS + 1][4];
int g_iLastPlayer[MAXPLAYERS + 1] = -1;
int g_iBalance[MAXPLAYERS + 1] = 0;

int g_iRed[4] =  { 255, 0, 0, 175 };
int g_iOrange[4] =  { 255, 128, 0, 175 };
int g_iYellow[4] =  { 255, 255, 0, 175 };
int g_iGreen[4] =  { 0, 255, 0, 175 };
int g_iBlue[4] =  { 0, 0, 255, 175 };
int g_iWhite[4] =  { 255, 255, 255, 175 };
int g_iGray[4] =  { 255, 255, 255, 300 };

Handle g_hCopyTimer;
Handle g_hGrabTimer;
Handle g_hHudTimer;
Handle g_hInLand;
Handle g_hLandDrawing;
Handle g_hMoney;
Handle g_hMusicLoop[MAXENTITIES + 1];
Handle g_hPositions;

public Plugin myinfo = 
{
	name = "|CelMod|", 
	author = PLUGIN_AUTHOR, 
	description = "A Living Project", 
	version = PLUGIN_VERSION, 
	url = "https://bitbucket.org/zaachhhh/celmod"
};

public void OnPluginStart()
{
	CM_RemoveMapProtection();
	
	AddCommandListener(Command_Freeze, "sm_freeze");
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
	
	BuildPath(Path_SM, g_sAreaDB, PLATFORM_MAX_PATH, "data/celmod/areas.txt");
	BuildPath(Path_SM, g_sBalanceDB, PLATFORM_MAX_PATH, "data/celmod/balances.txt");
	BuildPath(Path_SM, g_sColorDB, PLATFORM_MAX_PATH, "data/celmod/colors.txt");
	BuildPath(Path_SM, g_sDownloadDB, PLATFORM_MAX_PATH, "data/celmod/downloads.txt");
	BuildPath(Path_SM, g_sSoundDB, PLATFORM_MAX_PATH, "data/celmod/sounds.txt");
	BuildPath(Path_SM, g_sSpawnDB, PLATFORM_MAX_PATH, "data/celmod/spawns.txt");
	
	char sPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/saves");
	if (!DirExists(sPath))
	{
		CreateDirectory(sPath, 511);
	}
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	RegConsoleCmd("sm_cmsay", Command_CelModSay, "Allows you to type in chat as |CM|.");
	RegConsoleCmd("+copy", Command_StartCopy, "Starts copying the prop you are looking at.");
	RegConsoleCmd("+grab", Command_StartGrab, "Starts grabing the prop you are looking at.");
	RegConsoleCmd("-copy", Command_StopCopy, "Stops copying the prop.");
	RegConsoleCmd("-grab", Command_StopGrab, "Stops grabbing the prop.");
	RegConsoleCmd("sm_amt", Command_AMT, "Changes the alpha of the entity you are looking at.");
	RegConsoleCmd("sm_clearland", Command_ClearLand, "Clears your own land.");
	RegConsoleCmd("sm_color", Command_Color, "Colors the entity you are looking at.");
	RegConsoleCmd("sm_colorall", Command_ColorAll, "Colors all your entities.");
	RegConsoleCmd("sm_copy", Command_Copy, "Adds a prop to the copy queue.");
	RegConsoleCmd("sm_delete", Command_Delete, "Removes the entity you are looking at.");
	RegConsoleCmd("sm_deleteall", Command_DeleteAll, "Removes all your entities.");
	RegConsoleCmd("sm_del", Command_Delete, "Removes the entity you are looking at.");
	RegConsoleCmd("sm_delall", Command_DeleteAll, "Removes all your entities.");
	RegConsoleCmd("sm_door", Command_Door, "Spawns a door.");
	RegConsoleCmd("sm_flip", Command_Flip, "Flips the entity you are looking at.");
	RegConsoleCmd("sm_fly", Command_Fly, "Enables noclip on the client.");
	RegConsoleCmd("sm_hudcolor", Command_HudColor, "Changes the color of your hud and land.");
	RegConsoleCmd("sm_ignite", Command_Ignite, "Ignites the entity you are looking at.");
	RegConsoleCmd("sm_internet", Command_Internet, "Spawns a internet cel.");
	RegConsoleCmd("sm_land", Command_Land, "Creates a building zone.");
	RegConsoleCmd("sm_landgravity", Command_LandGravity, "Changes the land gravity.");
	RegConsoleCmd("sm_load", Command_LoadBuild, "Loads your saved build.");
	RegConsoleCmd("sm_music", Command_Music, "Creates a radio that plays music.");
	RegConsoleCmd("sm_moveto", Command_MoveTo, "Moves the entity you are looking at to a exact origin.");
	RegConsoleCmd("sm_owner", Command_Owner, "Prints the owner of the entity you are looking at in the chat.");
	RegConsoleCmd("sm_paste", Command_Paste, "Pastes what you have in your copy queue.");
	RegConsoleCmd("sm_r", Command_R, "Rotates the entity you are looking at.");
	RegConsoleCmd("sm_reply", Command_Reply, "Replies to the previous message.");
	RegConsoleCmd("sm_roll", Command_Roll, "Rolls the entity you are looking at.");
	RegConsoleCmd("sm_rotate", Command_Rotate, "Rotates the entity you are looking at.");
	RegConsoleCmd("sm_msg", Command_SendMessage, "Sends a private message to a player.");
	RegConsoleCmd("sm_save", Command_SaveBuild, "Saves all your props.");
	//RegConsoleCmd("sm_serverarea", Command_ServerArea, "Creates a saved land with specific properties with how clients handle it.");
	RegConsoleCmd("sm_seturl", Command_SetURL, "Sets the url of the internet cel you are looking at.");
	RegConsoleCmd("sm_skin", Command_Skin, "Changes the skin of the entity you are looking at.");
	RegConsoleCmd("sm_smove", Command_SMove, "Adds points to the origin of the entity that you are looking at.");
	RegConsoleCmd("sm_solid", Command_Solid, "Enables/disables solidicity on the entity you are looking at.");
	RegConsoleCmd("sm_sound", Command_Sound, "Creates a popcan that plays sounds.");
	RegConsoleCmd("sm_spawn", Command_Spawn, "Spawns a prop by alias.");
	RegConsoleCmd("sm_stack", Command_Stack, "Stacks the prop you are looking at.");
	RegConsoleCmd("sm_straight", Command_Straight, "Straightens the prop you are looking at.");
	RegConsoleCmd("sm_unfreeze", Command_UnFreeze, "Enables motion on the entity you are looking at.");
	
	g_hCelLimit = CreateConVar("cm_cel_limit", "25", "Limit's the number of cels that can be spawned.");
	g_hPropLimit = CreateConVar("cm_prop_limit", "175", "Limit's the number of props that can be spawn.");
	
	HookConVarChange(g_hCelLimit, CM_ConVarChanged);
	HookConVarChange(g_hPropLimit, CM_ConVarChanged);
	
	CM_SetCelLimit(GetConVarInt(g_hCelLimit));
	CM_SetPropLimit(GetConVarInt(g_hPropLimit));
	
	CM_DownloadFiles();
}

public void OnMapStart()
{
	CM_RemoveMapProtection();
	
	Format(g_sMusicModel, sizeof(g_sMusicModel), "models/props_lab/citizenradio.mdl");
	Format(g_sSoundModel, sizeof(g_sSoundModel), "models/props_junk/popcan01a.mdl");
	
	g_iBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_iHalo = PrecacheModel("materials/sprites/halo01.vmt", true);
	g_iLand = PrecacheModel("materials/sprites/spotlight.vmt", false);
	g_iPhys = PrecacheModel("materials/sprites/physbeam.vmt", true);
	
	g_iEntityDissolver = CreateEntityByName("env_entity_dissolver");
	g_iEntityIgniter = CreateEntityByName("env_entity_igniter");
	
	DispatchKeyValue(g_iEntityDissolver, "dissolvetype", "3");
	DispatchKeyValue(g_iEntityDissolver, "magnitude", "250");
	DispatchKeyValue(g_iEntityDissolver, "target", "dissolved");
	DispatchKeyValue(g_iEntityDissolver, "targetname", "entity_dissolver");
	
	DispatchKeyValue(g_iEntityIgniter, "lifetime", "60");
	DispatchKeyValue(g_iEntityIgniter, "target", "ignited");
	DispatchKeyValue(g_iEntityIgniter, "targetname", "entity_igniter");
	
	DispatchSpawn(g_iEntityDissolver);
	DispatchSpawn(g_iEntityIgniter);
	
	g_hCopyTimer = CreateTimer(0.1, Timer_Copy, _, TIMER_REPEAT);
	g_hGrabTimer = CreateTimer(0.1, Timer_Grab, _, TIMER_REPEAT);
	
	g_hHudTimer = CreateTimer(0.1, Timer_Hud, _, TIMER_REPEAT);
	
	g_hInLand = CreateTimer(0.1, Timer_InLand, _, TIMER_REPEAT);
	g_hLandDrawing = CreateTimer(0.1, Timer_DrawLand, _, TIMER_REPEAT);
	
	g_hMoney = CreateTimer(240.0, Timer_AddMoney, _, TIMER_REPEAT);
	
	g_hPositions = CreateTimer(0.1, Timer_Positions, _, TIMER_REPEAT);
}

public void OnMapEnd()
{
	CloseHandle(g_hCopyTimer);
	CloseHandle(g_hGrabTimer);
	CloseHandle(g_hHudTimer);
	CloseHandle(g_hInLand);
	CloseHandle(g_hLandDrawing);
	CloseHandle(g_hMoney);
	CloseHandle(g_hPositions);
}

public void OnClientPutInServer(int iClient)
{
	char sPath[PLATFORM_MAX_PATH];
	
	CM_SetAuthID(iClient);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/saves/%s", g_sAuthID[iClient]);
	if (!DirExists(sPath))
	{
		CreateDirectory(sPath, 511);
	}
	
	CM_SetCelCount(iClient, 0);
	CM_SetPropCount(iClient, 0);
	
	g_iCopyEnt[iClient] = -1;
	g_iGrabEnt[iClient] = -1;
	
	g_iBalance[iClient] = 0;
	
	CM_LoadClientBalance(iClient);
	
	g_iLastPlayer[iClient] = -1;
	
	g_fLandOrigin[iClient][0] = g_fZero;
	g_fLandOrigin[iClient][1] = g_fZero;
	
	g_bConnected[iClient] = true;
	g_bCopyQueue[iClient] = false;
	g_bGettingPositions[iClient] = false;
	g_bGodMode[iClient] = false;
	g_bIsInLand[iClient] = false;
	g_bLandDrawing[iClient] = false;
	g_bSentMessage[iClient] = false;
	g_bStartedLand[iClient] = false;
	g_bButtonUse[iClient] = false;
	
	g_fEntityTime[iClient] = 0.0;
	
	switch (GetRandomInt(0, 6))
	{
		case 0:
		{
			g_iClientColor[iClient] = g_iRed;
		}
		case 1:
		{
			g_iClientColor[iClient] = g_iOrange;
		}
		case 2:
		{
			g_iClientColor[iClient] = g_iYellow;
		}
		case 3:
		{
			g_iClientColor[iClient] = g_iGreen;
		}
		case 4:
		{
			g_iClientColor[iClient] = g_iBlue;
		}
		case 5:
		{
			g_iClientColor[iClient] = g_iWhite;
		}
		case 6:
		{
			g_iClientColor[iClient] = g_iGray;
		}
	}
	
	ClientCommand(iClient, "r_screenoverlay celmod/cm_overlay2.vmt");
}

public void OnClientDisconnect(int iClient)
{
	g_iCopyEnt[iClient] = -1;
	g_iGrabEnt[iClient] = -1;
	
	g_iLastPlayer[iClient] = -1;
	
	CM_SaveClientBalance(iClient);
	
	g_bConnected[iClient] = false;
	g_bCopyQueue[iClient] = false;
	g_bGettingPositions[iClient] = false;
	g_bGodMode[iClient] = false;
	g_bIsInLand[iClient] = false;
	g_bLandDrawing[iClient] = false;
	g_bSentMessage[iClient] = false;
	g_bStartedLand[iClient] = false;
	g_bButtonUse[iClient] = false;
	
	g_fEntityTime[iClient] = 0.0;
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			if (g_iLastPlayer[i] == iClient)
			{
				g_iLastPlayer[i] = -1;
			}
		}
	}
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (CM_CheckOwner(iClient, i))
		{
			CreateTimer(0.10, Timer_Remove, i);
		}
	}
	
	ClientCommand(iClient, "r_screenoverlay 0");
}

/*public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdnum, int &iTickcount, int &iSeed, int iMouse[2])
{
	char sClassname[64];
	
	float fClientOrigin[3], fEntityOrigin[3];
	
	if (GetClientButtons(iClient) & IN_USE)
	{
		if (GetClientAimTarget(iClient, false) != -1)
		{
			int iEntity = GetClientAimTarget(iClient, false);
			
			if (g_bCMEntity[iEntity])
			{
				GetClientAbsOrigin(iClient, fClientOrigin);
				CM_GetEntityOrigin(iEntity, fEntityOrigin);
				
				float fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
				
				GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
				
				if (StrEqual(sClassname, "cel_sound"))
				{
					if (g_fEntityTime[iClient] < GetGameTime() - 1)
					{
						if (fDistance <= 50)
						{
							PrecacheSound(g_sSound[iEntity]);
							EmitSoundToAll(g_sSound[iEntity], iEntity, 2, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
						}
						
						g_fEntityTime[iClient] = GetGameTime();
					}
				}
				
				if (StrEqual(sClassname, "cel_internet"))
				{
					if (g_fEntityTime[iClient] < GetGameTime() - 1)
					{
						if (fDistance <= 50)
						{
							ShowMOTDPanel(iClient, "|CelMod| Viewer", g_sInternetURL[iEntity], MOTDPANEL_TYPE_URL);
						}
						
						g_fEntityTime[iClient] = GetGameTime();
					}
				}
				
				if (StrEqual(sClassname, "cel_music"))
				{
					if (g_fEntityTime[iClient] < GetGameTime() - 1)
					{
						
						if (fDistance <= 150)
						{
							if (g_bPlaying[iEntity])
							{
								StopSound(iEntity, 0, g_sMusic[iEntity]);
								
								g_bPlaying[iEntity] = false;
							} else {
								PrecacheSound(g_sMusic[iEntity]);
								EmitSoundToAll(g_sMusic[iEntity], iEntity, 3, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
								
								if (g_bLoop[iEntity])
								{
									g_hMusicLoop[iEntity] = CreateTimer(g_fMusicTime[iEntity], Timer_RepeatMusic, iEntity, TIMER_REPEAT);
								}
								
								g_bPlaying[iEntity] = true;
							}
						}
						g_fEntityTime[iClient] = GetGameTime();
					}
				}
			}
		}
	}
}*/

public void OnButtonPressed(int iClient, int iButton)
{
	char sClassname[64];
	
	float fClientOrigin[3], fEntityOrigin[3];
	
	if(iButton == 32)
	{
		if(!g_bButtonUse[iClient])
		{
			g_bButtonUse[iClient] = true;
			
			if (GetClientAimTarget(iClient, false) != -1)
			{
				int iEntity = GetClientAimTarget(iClient, false);
				
				if (g_bCMEntity[iEntity])
				{
					GetClientAbsOrigin(iClient, fClientOrigin);
					CM_GetEntityOrigin(iEntity, fEntityOrigin);
					
					float fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
					
					GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
					
					if (StrEqual(sClassname, "cel_sound"))
					{
						if (g_fEntityTime[iClient] < GetGameTime() - 1)
						{
							if (fDistance <= 50)
							{
								PrecacheSound(g_sSound[iEntity]);
								EmitSoundToAll(g_sSound[iEntity], iEntity, 2, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
							}
							
							g_fEntityTime[iClient] = GetGameTime();
						}
					}
					
					if (StrEqual(sClassname, "cel_internet"))
					{
						if (g_fEntityTime[iClient] < GetGameTime() - 1)
						{
							if (fDistance <= 50)
							{
								ShowMOTDPanel(iClient, "|CelMod| Viewer", g_sInternetURL[iEntity], MOTDPANEL_TYPE_URL);
							}
							
							g_fEntityTime[iClient] = GetGameTime();
						}
					}
					
					if (StrEqual(sClassname, "cel_music"))
					{
						if (g_fEntityTime[iClient] < GetGameTime() - 1)
						{
							
							if (fDistance <= 150)
							{
								if (g_bPlaying[iEntity])
								{
									StopSound(iEntity, 0, g_sMusic[iEntity]);
									
									g_bPlaying[iEntity] = false;
								} else {
									PrecacheSound(g_sMusic[iEntity]);
									EmitSoundToAll(g_sMusic[iEntity], iEntity, 3, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
									
									if (g_bLoop[iEntity])
									{
										g_hMusicLoop[iEntity] = CreateTimer(g_fMusicTime[iEntity], Timer_RepeatMusic, iEntity, TIMER_REPEAT);
									}
									
									g_bPlaying[iEntity] = true;
								}
							}
							g_fEntityTime[iClient] = GetGameTime();
						}
					}
				}
			}
		}
	}
}

public void OnButtonReleased(int iClient, int iButton)
{
	if(g_bButtonUse[iClient])
	{
		g_bButtonUse[iClient] = false;
	}
}

public Action Event_PlayerSpawn(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iUserID = hEvent.GetInt("userid");
	
	int iClient = GetClientOfUserId(iUserID);
	
	CM_SetGodMode(iClient, CM_GetGodMode(iClient));
}

public Action Command_AMT(int iClient, int iArgs)
{
	char sAlpha[64];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!amt{default} <{green}alpha{default}>");
		return Plugin_Handled;
	}
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlpha, sizeof(sAlpha));
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		int iAlpha = StringToInt(sAlpha);
		
		CM_SetEntityColor(iEntity, g_iColor[iEntity][0], g_iColor[iEntity][1], g_iColor[iEntity][2], iAlpha);
		
		CM_ChangeBeam(iClient, iEntity);
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} Alpha transparency has been changed to {green}%i{default}.", iAlpha);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_CelModSay(int iClient, int iArgs)
{
	if (SAS_CheckAdmin(iClient))
	{
		if (SAS_CheckAdminLevel(iClient, 3))
		{
			char sMessage[512];
			
			GetCmdArgString(sMessage, sizeof(sMessage));
			
			CPrintToChatAll("{blue}|CM|{default} %s", sMessage);
			
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

public Action Command_ClearLand(int iClient, int iArgs)
{
	g_bStartedLand[iClient] = false;
	g_bLandDrawing[iClient] = false;
	g_bGettingPositions[iClient] = false;
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} Your land has been cleared.");
	
	return Plugin_Handled;
}

public Action Command_Color(int iClient, int iArgs)
{
	char sColor[64], sColorString[96], sColorBuffer[3][32];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!color{default} <{green}color{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor, sizeof(sColor));
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		KeyValues hColors = CreateKeyValues("Colors");
		
		FileToKeyValues(hColors, g_sColorDB);
		
		KvGetString(hColors, sColor, sColorString, sizeof(sColorString), "null");
		
		if (StrEqual(sColorString, "null"))
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} Color not found in database.");
			return Plugin_Handled;
		}
		
		CloseHandle(hColors);
		
		ExplodeString(sColorString, "^", sColorBuffer, 3, sizeof(sColorBuffer[]));
		
		CM_SetEntityColor(iEntity, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), g_iColor[iEntity][3]);
		
		g_bFadeColor[iEntity] = false;
		
		CM_ChangeBeam(iClient, iEntity);
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} Set entity color to {green}%s{default}.", sColor);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_ColorAll(int iClient, int iArgs)
{
	char sColor[64], sColorString[96], sColorBuffer[3][32];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!colorall{default} <{green}color{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor, sizeof(sColor));
	
	KeyValues hColors = CreateKeyValues("Colors");
	
	FileToKeyValues(hColors, g_sColorDB);
	
	KvGetString(hColors, sColor, sColorString, sizeof(sColorString), "null");
	
	if (StrEqual(sColorString, "null"))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Color not found in database.");
		return Plugin_Handled;
	}
	
	CloseHandle(hColors);
	
	ExplodeString(sColorString, "^", sColorBuffer, 3, sizeof(sColorBuffer[]));
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (CM_CheckOwner(iClient, i) && IsValidEntity(i))
		{
			CM_SetEntityColor(i, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), g_iColor[i][3]);
			
			g_bFadeColor[i] = false;
		}
	}
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} Set all entities color to {green}%s{default}.", sColor);
	
	return Plugin_Handled;
}

public Action Command_Copy(int iClient, int iArgs)
{
	char sModel[128], sPropname[64], sSkin[64], sSolid[64];
	int iColor[4];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (!g_bCanCopy[iEntity])
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You cannot copy this entity!");
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		IntToString(GetEntProp(iEntity, Prop_Data, "m_nSkin", 1), sSkin, sizeof(sSkin));
		IntToString(GetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 4, 0), sSolid, sizeof(sSolid));
		
		GetEntityRenderColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
		
		CM_GetPropName(iEntity, sPropname);
		
		Format(g_sCopyInformation[iClient][0], sizeof(g_sCopyInformation[][]), sModel);
		Format(g_sCopyInformation[iClient][1], sizeof(g_sCopyInformation[][]), sSkin);
		Format(g_sCopyInformation[iClient][2], sizeof(g_sCopyInformation[][]), sSolid);
		IntToString(iColor[0], g_sCopyInformation[iClient][3], sizeof(g_sCopyInformation[][]));
		IntToString(iColor[1], g_sCopyInformation[iClient][4], sizeof(g_sCopyInformation[][]));
		IntToString(iColor[2], g_sCopyInformation[iClient][5], sizeof(g_sCopyInformation[][]));
		IntToString(iColor[3], g_sCopyInformation[iClient][6], sizeof(g_sCopyInformation[][]));
		Format(g_sCopyInformation[iClient][7], sizeof(g_sCopyInformation[][]), sPropname);
		
		CM_ChangeBeam(iClient, iEntity);
		
		g_bCopyQueue[iClient] = true;
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} Added prop to copy queue.");
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Delete(int iClient, int iArgs)
{
	char sClassname[64];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iTarget = GetClientAimTarget(iClient, false);
	
	int iEntity = EntRefToEntIndex(iTarget);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
		
		g_bCanCopy[iEntity] = false;
		
		if (StrContains(sClassname, "prop_") != -1)
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} Removed physics entity.");
			
			CM_SubFromPropCount(iClient);
		} else if (StrContains(sClassname, "cel_") != -1)
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} Removed cel entity.");
			
			CM_SubFromCelCount(iClient);
		} else if (StrEqual(sClassname, "cel_music"))
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} Removed music cel.");
			
			StopSound(iEntity, 3, g_sMusic[iEntity]);
			
			g_bLoop[iEntity] = false;
			g_bPlaying[iEntity] = false;
			
			CM_SubFromCelCount(iClient);
		} else if (StrEqual(sClassname, "cel_sound"))
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} Removed sound cel.");
			
			CM_SubFromCelCount(iClient);
		}
		
		CM_DissolveEntity(iEntity);
		
		CM_RemovalBeam(iClient, iEntity);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_DeleteAll(int iClient, int iArgs)
{
	int iFinal = CM_GetCelCount(iClient) + CM_GetPropCount(iClient);
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (CM_CheckOwner(iClient, i))
		{
			CreateTimer(0.10, Timer_Remove, i);
		}
	}
	
	CM_SetCelCount(iClient, 0);
	CM_SetPropCount(iClient, 0);
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} Removed {green}%i{default} entities.", iFinal);
	
	return Plugin_Handled;
}

public Action Command_Door(int iClient, int iArgs)
{
	if (CM_CheckPropCount(iClient))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You have reached the max cel limit.");
		return Plugin_Handled;
	}
	
	char sSkin[64];
	float fOrigin[3], fAngles[3];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!door{default} <{green}skin{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sSkin, sizeof(sSkin));
	
	CM_GetEndPoint(iClient, fOrigin);
	GetClientAbsAngles(iClient, fAngles);
	
	CM_SpawnDoor(iClient, sSkin, fOrigin, fAngles, 255, 255, 255, 255);
	
	return Plugin_Handled;
}

public Action Command_FadeColor(int iClient, int iArgs)
{
	char sColor[64], sColor2[64], sColorString[96], sColorString2[96], sColorBuffer[3][32], sColorBuffer2[3][32];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!fadecolor{default} <{green}first color{default}> <{green}second color{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor, sizeof(sColor));
	GetCmdArg(1, sColor2, sizeof(sColor2));
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		KeyValues hColors = CreateKeyValues("Colors");
		
		FileToKeyValues(hColors, g_sColorDB);
		
		KvGetString(hColors, sColor, sColorString, sizeof(sColorString), "null");
		
		if (StrEqual(sColorString, "null"))
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} {green}%s{default} not found in database.", sColor);
			return Plugin_Handled;
		}
		
		KvRewind(hColors);
		
		KvGetString(hColors, sColor2, sColorString2, sizeof(sColorString2), "null");
		
		if (StrEqual(sColorString2, "null"))
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} {green}%s{default} not found in database.", sColor2);
			return Plugin_Handled;
		}
		
		CloseHandle(hColors);
		
		ExplodeString(sColorString, "^", sColorBuffer, 3, sizeof(sColorBuffer[]));
		ExplodeString(sColorString2, "^", sColorBuffer2, 3, sizeof(sColorBuffer2[]));
		
		CM_SetEntityColor(iEntity, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), g_iColor[iEntity][3]);
		
		g_bFadeColor[iEntity] = false;
		
		CM_ChangeBeam(iClient, iEntity);
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} Set entity color to {green}%s{default}.", sColor);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Flip(int iClient, int iArgs)
{
	char sDegree[64];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!flip{default} <{green}degree{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sDegree, sizeof(sDegree));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		FakeClientCommand(iClient, "sm_rotate %s 0 0", sDegree);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Fly(int iClient, int iArgs)
{
	MoveType iMoveType = GetEntityMoveType(iClient);
	
	if (iMoveType == MOVETYPE_NOCLIP)
	{
		SetEntityMoveType(iClient, MOVETYPE_WALK);
		CPrintToChat(iClient, "{blue}|CelMod|{default} Noclip has been disabled.");
	} else {
		SetEntityMoveType(iClient, MOVETYPE_NOCLIP);
		CPrintToChat(iClient, "{blue}|CelMod|{default} Noclip has been enabled.");
	}
	
	return Plugin_Handled;
}

public Action Command_Freeze(int iClient, const char[] sCommand, int iArgs)
{
	char sClassname[64];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
		
		if (StrContains(sClassname, "prop_door_rotating") != -1)
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} Door has been locked.");
			
			AcceptEntityInput(iEntity, "lock");
		} else {
			CPrintToChat(iClient, "{blue}|CelMod|{default} Disabled motion on %s entity.", StrContains(sClassname, "prop_") != -1 ? "prop" : "cel");
			
			AcceptEntityInput(iEntity, "disablemotion");
		}
		
		CM_ChangeBeam(iClient, iEntity);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_HudColor(int iClient, int iArgs)
{
	char sColor[64], sColorString[96], sColorBuffer[3][32];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!hudcolor{default} <{green}color{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor, sizeof(sColor));
	
	KeyValues hColors = CreateKeyValues("Colors");
	
	FileToKeyValues(hColors, g_sColorDB);
	
	KvGetString(hColors, sColor, sColorString, sizeof(sColorString), "null");
	
	if (StrEqual(sColorString, "null"))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Color not found in database.");
		return Plugin_Handled;
	}
	
	CloseHandle(hColors);
	
	ExplodeString(sColorString, "^", sColorBuffer, 3, sizeof(sColorBuffer[]));
	
	g_iClientColor[iClient][0] = StringToInt(sColorBuffer[0]);
	g_iClientColor[iClient][1] = StringToInt(sColorBuffer[1]);
	g_iClientColor[iClient][2] = StringToInt(sColorBuffer[2]);
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} Set hud color to {green}%s{default}.", sColor);
	
	return Plugin_Handled;
}

public Action Command_Ignite(int iClient, int iArgs)
{
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		DispatchKeyValue(iEntity, "targetname", "ignited");
		
		AcceptEntityInput(g_iEntityIgniter, "ignite");
		
		CM_ChangeBeam(iClient, iEntity);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Internet(int iClient, int iArgs)
{
	if (CM_CheckCelCount(iClient))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You have reached the cel prop limit.");
		return Plugin_Handled;
	}
	
	float fAngles[3], fCOrigin[3], fOrigin[3];
	
	GetClientAbsOrigin(iClient, fCOrigin);
	GetClientEyeAngles(iClient, fAngles);
	
	fOrigin[0] = FloatAdd(fCOrigin[0], Cosine(DegToRad(fAngles[1])) * 50);
	fOrigin[1] = FloatAdd(fCOrigin[1], Sine(DegToRad(fAngles[1])) * 50);
	fOrigin[2] = fCOrigin[2] + 32;
	
	CM_SpawnInternet(iClient, "http://xfusionlockx.x10host.com/celmod/", fOrigin, g_fZero, 255, 255, 255, 255);
	
	return Plugin_Handled;
}

public Action Command_Land(int iClient, int iArgs)
{
	bool bDidHitTop = false;
	float fOrigin[3];
	
	if (g_bStartedLand[iClient])
	{
		CM_GetEndPoint(iClient, fOrigin);
		
		g_bStartedLand[iClient] = false;
		g_bGettingPositions[iClient] = false;
		
		for (int i = 0; i < 16384; i++)
		{
			if (bDidHitTop)
			{
				g_fLandOrigin[iClient][1] = fOrigin;
			} else {
				fOrigin[2] += 1;
				
				if (TR_PointOutsideWorld(fOrigin))
				{
					fOrigin[2] -= 2;
					
					bDidHitTop = true;
					
					g_fLandOrigin[iClient][1] = fOrigin;
				}
			}
		}
		
		g_fLandOrigin[iClient][1] = fOrigin;
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} Land completed.");
		
		return Plugin_Handled;
	} else {
		g_bStartedLand[iClient] = true;
		g_bLandDrawing[iClient] = true;
		g_bGettingPositions[iClient] = true;
		
		CM_GetEndPoint(iClient, fOrigin);
		
		g_fLandOrigin[iClient][0] = fOrigin;
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} Type {green}!land{default} again to complete the land.");
		
		return Plugin_Handled;
	}
}

public Action Command_LandGravity(int iClient, int iArgs)
{
	Menu mGravity = new Menu(Menu_Gravity, MENU_ACTIONS_ALL);
	
	mGravity.SetTitle("Land Gravity");
	
	mGravity.AddItem("Low", "Low");
	mGravity.AddItem("Normal", "Normal");
	mGravity.AddItem("High", "High");
	
	mGravity.ExitButton = true;
	
	mGravity.Display(iClient, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public Action Command_LoadBuild(int iClient, int iArgs)
{
	char sArg[128];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!load{default} <{green}buildname{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sArg, sizeof(sArg));
	
	CM_LoadBuild(iClient, sArg);
	
	return Plugin_Handled;
}

public Action Command_Music(int iClient, int iArgs)
{
	if (CM_CheckCelCount(iClient))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You have reached the cel prop limit.");
		return Plugin_Handled;
	}
	
	bool bLoop = false;
	char sAlias[64], sLoop[64], sSound[128];
	float fOrigin[3], fCOrigin[3], fAngles[3];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!music{default} <{green}alias{default}> <{green}loop (0 or 1){default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	GetCmdArg(2, sLoop, sizeof(sLoop));
	
	if (StrEqual(sLoop, "0"))
	{
		bLoop = false;
	} else if (StrEqual(sLoop, "1"))
	{
		bLoop = true;
	} else if (StrEqual(sLoop, ""))
	{
		bLoop = false;
	} else {
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!music{default} <{green}alias{default}> <{green}loop (0 or 1){default}>");
		return Plugin_Handled;
	}
	
	KeyValues hSound = CreateKeyValues("Vault");
	
	FileToKeyValues(hSound, g_sSoundDB);
	
	KvJumpToKey(hSound, "Music");
	
	KvGetString(hSound, sAlias, sSound, sizeof(sSound), "null");
	
	if (StrEqual(sSound, "null"))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} {green}%s{default} does not exist in the music database!", sAlias);
		return Plugin_Handled;
	}
	
	CloseHandle(hSound);
	
	GetClientAbsOrigin(iClient, fCOrigin);
	GetClientEyeAngles(iClient, fAngles);
	
	fOrigin[0] = FloatAdd(fCOrigin[0], Cosine(DegToRad(fAngles[1])) * 50);
	fOrigin[1] = FloatAdd(fCOrigin[1], Sine(DegToRad(fAngles[1])) * 50);
	fOrigin[2] = fCOrigin[2] + 32;
	
	CM_SpawnMusic(iClient, sAlias, sSound, bLoop, fOrigin, g_fZero, 0, 255, 0, 255);
	
	return Plugin_Handled;
}

public Action Command_MoveTo(int iClient, int iArgs)
{
	char sX[64], sY[64], sZ[64];
	float fOrigin[3];
	
	if (iArgs < 3)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!moveto{default} <{green}x{default}> <{green}y{default}> <{green}z{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(3, sZ, sizeof(sZ));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		fOrigin[0] = StringToFloat(sX);
		fOrigin[1] = StringToFloat(sY);
		fOrigin[2] = StringToFloat(sZ);
		
		TeleportEntity(iEntity, fOrigin, NULL_VECTOR, NULL_VECTOR);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Owner(int iClient, int iArgs)
{
	char sClassname[64];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} Owner of this {green}%s{default} is {green}%N{default}.", StrContains(sClassname, "prop_") != -1 ? "prop" : "cel", g_iOwner[iEntity]);
	
	return Plugin_Handled;
}

public Action Command_Paste(int iClient, int iArgs)
{
	float fAngles[3], fOrigin[3];
	
	if (CM_CheckPropCount(iClient))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You have reached the max prop limit.");
		return Plugin_Handled;
	}
	
	if (!g_bCopyQueue[iClient])
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You have nothing in your copy queue!");
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	CM_GetEndPoint(iClient, fOrigin);
	
	int iEntity = CreateEntityByName("prop_physics_override");
	
	PrecacheModel(g_sCopyInformation[iClient][0]);
	
	DispatchKeyValue(iEntity, "model", g_sCopyInformation[iClient][0]);
	DispatchKeyValue(iEntity, "skin", g_sCopyInformation[iClient][1]);
	
	DispatchSpawn(iEntity);
	
	CM_SetEntityColor(iEntity, StringToInt(g_sCopyInformation[iClient][3]), StringToInt(g_sCopyInformation[iClient][4]), StringToInt(g_sCopyInformation[iClient][5]), StringToInt(g_sCopyInformation[iClient][6]));
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	CM_SetPropName(iEntity, g_sCopyInformation[iClient][7]);
	
	SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", StringToInt(g_sCopyInformation[iClient][2]));
	
	g_iOwner[iEntity] = iClient;
	
	CM_AddToPropCount(iClient);
	
	g_bCMEntity[iEntity] = true;
	
	g_bCanCopy[iEntity] = true;
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} Pasted prop in your copy queue!");
	
	CM_ChangeBeam(iClient, iEntity);
	
	return Plugin_Handled;
}

public Action Command_R(int iClient, int iArgs)
{
	char sDegree[64];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!r{default} <{green}degree{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sDegree, sizeof(sDegree));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		FakeClientCommand(iClient, "sm_rotate 0 %s 0", sDegree);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Reply(int iClient, int iArgs)
{
	char sMessage[512];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!reply{default} <{green}message{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArgString(sMessage, sizeof(sMessage));
	
	if (g_iLastPlayer[iClient] == -1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} No-one has messaged you yet! Type {green}!msg{default} to message someone!");
		return Plugin_Handled;
	}
	
	CPrintToChat(iClient, "{blue}|CM|{default} To: {green}%N{default} - %s", g_iLastPlayer[iClient], sMessage);
	CPrintToChat(g_iLastPlayer[iClient], "{blue}|CM|{default} From: {green}%N{default} - %s", iClient, sMessage);
	
	ClientCommand(g_iLastPlayer[iClient], "play friends/message.wav");
	
	return Plugin_Handled;
}

public Action Command_Roll(int iClient, int iArgs)
{
	char sDegree[64];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!roll{default} <{green}degree{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sDegree, sizeof(sDegree));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		FakeClientCommand(iClient, "sm_rotate 0 0 %s", sDegree);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Rotate(int iClient, int iArgs)
{
	char sX[64], sY[64], sZ[64];
	float fAngles[3];
	
	if (iArgs < 3)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!rotate{default} <{green}x{default}> <{green}y{default}> <{green}z{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(3, sZ, sizeof(sZ));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		CM_GetEntityAngles(iEntity, fAngles);
		
		fAngles[0] += StringToFloat(sX);
		fAngles[1] += StringToFloat(sY);
		fAngles[2] += StringToFloat(sZ);
		
		TeleportEntity(iEntity, NULL_VECTOR, fAngles, NULL_VECTOR);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_SaveBuild(int iClient, int iArgs)
{
	char sArg[128];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!save{default} <{green}buildname{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sArg, sizeof(sArg));
	
	CM_SaveBuild(iClient, sArg);
	
	return Plugin_Handled;
}

public Action Command_Say(int iClient, const char[] sCommand, int iArgs)
{
	if (IsChatTrigger())
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Command_SendMessage(int iClient, int iArgs)
{
	char sArg[128], sMessage[512];
	
	if (iArgs < 2)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!msg{default} <{green}recipent{default}> <{green}message{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sArg, sizeof(sArg));
	GetCmdArgString(sMessage, sizeof(sMessage));
	
	int iTarget = FindTarget(iClient, sArg, true, false);
	
	if (iTarget == -1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} {green}%N{default} is not a valid client!", iTarget);
		return Plugin_Handled;
	}
	
	if (iTarget == iClient)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You cannot message yourself!");
		return Plugin_Handled;
	}
	
	ReplaceString(sMessage, sizeof(sMessage), sArg, "", true);
	TrimString(sMessage);
	
	CPrintToChat(iClient, "{blue}|CM|{default} To: {green}%N{default} - %s", iTarget, sMessage);
	CPrintToChat(iTarget, "{blue}|CM|{default} From: {green}%N{default} - %s", iClient, sMessage);
	
	g_iLastPlayer[iClient] = iTarget;
	
	ClientCommand(iTarget, "play friends/message.wav");
	
	return Plugin_Handled;
}

public Action Command_SetURL(int iClient, int iArgs)
{
	char sURL[256];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!seturl{default} <{green}url{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArgString(sURL, sizeof(sURL));
	
	if (StrContains(sURL, "http://", false) != -1 || StrContains(sURL, "https://", false) != -1)
	{  } else {
		Format(sURL, sizeof(sURL), "http://%s", sURL);
	}
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		CM_SetInternetURL(iEntity, sURL);
		
		CM_ChangeBeam(iClient, iEntity);
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} Set internet url to {green}%s{default}.", sURL);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Skin(int iClient, int iArgs)
{
	char sSkin[64];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!skin{default} <{green}skin{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sSkin, sizeof(sSkin));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		DispatchKeyValue(iEntity, "skin", sSkin);
		
		CM_ChangeBeam(iClient, iEntity);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_SMove(int iClient, int iArgs)
{
	char sX[64], sY[64], sZ[64];
	float fOrigin[3];
	
	if (iArgs < 3)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!smove{default} <{green}x{default}> <{green}y{default}> <{green}z{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(3, sZ, sizeof(sZ));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		CM_GetEntityOrigin(iEntity, fOrigin);
		
		fOrigin[0] += StringToFloat(sX);
		fOrigin[1] += StringToFloat(sY);
		fOrigin[2] += StringToFloat(sZ);
		
		TeleportEntity(iEntity, fOrigin, NULL_VECTOR, NULL_VECTOR);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Solid(int iClient, int iArgs)
{
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		if (g_bSolid[iEntity])
		{
			DispatchKeyValue(iEntity, "solid", "4");
			
			CPrintToChat(iClient, "{blue}|CelMod|{default} Turned solidicity off.");
			
			g_bSolid[iEntity] = false;
		} else {
			DispatchKeyValue(iEntity, "solid", "6");
			
			CPrintToChat(iClient, "{blue}|CelMod|{default} Turned solidicity on.");
			
			g_bSolid[iEntity] = true;
		}
		
		CM_ChangeBeam(iClient, iEntity);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Sound(int iClient, int iArgs)
{
	if (CM_CheckCelCount(iClient))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You have reached the cel prop limit.");
		return Plugin_Handled;
	}
	
	char sAlias[64], sSound[128];
	float fOrigin[3], fCOrigin[3], fAngles[3];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!sound{default} <{green}alias{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	
	KeyValues hSound = CreateKeyValues("Vault");
	
	FileToKeyValues(hSound, g_sSoundDB);
	
	KvJumpToKey(hSound, "Sounds");
	
	KvGetString(hSound, sAlias, sSound, sizeof(sSound), "null");
	
	if (StrEqual(sSound, "null"))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} {green}%s{default} does not exist in the sound database!", sAlias);
		return Plugin_Handled;
	}
	
	CloseHandle(hSound);
	
	GetClientAbsOrigin(iClient, fCOrigin);
	GetClientEyeAngles(iClient, fAngles);
	
	fOrigin[0] = FloatAdd(fCOrigin[0], Cosine(DegToRad(fAngles[1])) * 50);
	fOrigin[1] = FloatAdd(fCOrigin[1], Sine(DegToRad(fAngles[1])) * 50);
	fOrigin[2] = fCOrigin[2] + 32;
	
	CM_SpawnSound(iClient, sAlias, sSound, fOrigin, g_fZero, 255, 128, 0, 255);
	
	return Plugin_Handled;
}

public Action Command_Spawn(int iClient, int iArgs)
{
	if (CM_CheckPropCount(iClient))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You have reached the max prop limit.");
		return Plugin_Handled;
	}
	
	char sAlias[64], sModel[128], sSpawnMode[128];
	float fOrigin[3], fAngles[3];
	
	if (iArgs < 1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: {green}!spawn{default} <{green}alias{default}>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	
	KeyValues hSpawn = CreateKeyValues("Props");
	
	FileToKeyValues(hSpawn, g_sSpawnDB);
	
	if (KvJumpToKey(hSpawn, sAlias, false))
	{
		KvGetString(hSpawn, "model", sModel, sizeof(sModel), "null");
		KvGetString(hSpawn, "spawnmode", sSpawnMode, sizeof(sSpawnMode), "null");
	} else {
		CPrintToChat(iClient, "{blue}|CelMod|{default} {green}%s{default} does not exist in the spawn database!", sAlias);
		return Plugin_Handled;
	}
	
	CM_GetEndPoint(iClient, fOrigin);
	GetClientAbsAngles(iClient, fAngles);
	
	CM_SpawnProp(iClient, sAlias, sModel, sSpawnMode, fOrigin, fAngles, 255, 255, 255, 255);
	
	return Plugin_Handled;
}

public Action Command_Stack(int iClient, int iArgs)
{
	char sModel[128], sPropname[64], sSkin[64], sSolid[64], sAmount[64], sX[16], sY[16], sZ[16];
	float fAddOrigin[3], fAngles[3], fEntityOrigin[3], fOldOrigin[3], fOrigin[3];
	int iColor[4];
	
	if (iArgs < 4)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Usage: !stack <amount> <x> <y> <z>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAmount, sizeof(sAmount));
	GetCmdArg(2, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(2, sZ, sizeof(sZ));
	
	int iAmount = StringToInt(sAmount);
	
	fAddOrigin[0] = StringToFloat(sX), fAddOrigin[1] = StringToFloat(sY), fAddOrigin[2] = StringToFloat(sZ);
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (!g_bCanCopy[iEntity])
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You cannot stack this entity!");
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		IntToString(GetEntProp(iEntity, Prop_Data, "m_nSkin", 1), sSkin, sizeof(sSkin));
		IntToString(GetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 4, 0), sSolid, sizeof(sSolid));
		
		GetEntityRenderColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
		
		CM_GetPropName(iEntity, sPropname);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	CM_GetEntityAngles(iEntity, fAngles);
	CM_GetEntityOrigin(iEntity, fEntityOrigin);
	
	int iStackCount;
	
	for (int i = 0; i < iAmount; i++)
	{
		if (CM_CheckPropCount(iClient))
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} You have reached the max prop limit.");
			return Plugin_Handled;
		}
		
		iStackCount++;
		
		fOldOrigin[0] = fAddOrigin[0] * iStackCount;
		fOldOrigin[1] = fAddOrigin[1] * iStackCount;
		fOldOrigin[2] = fAddOrigin[2] * iStackCount;
		
		AddVectors(fEntityOrigin, fOldOrigin, fOrigin);
		
		int iProp = CreateEntityByName("prop_physics_override");
		
		PrecacheModel(sModel);
		
		DispatchKeyValue(iProp, "model", sModel);
		DispatchKeyValue(iProp, "skin", sSkin);
		
		DispatchSpawn(iProp);
		
		SetEntProp(iProp, Prop_Send, "m_CollisionGroup", StringToInt(sSolid));
		
		AcceptEntityInput(iProp, "disablemotion");
		
		TeleportEntity(iProp, fOrigin, fAngles, NULL_VECTOR);
		
		CM_SetEntityColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
		
		CM_SetPropName(iProp, sPropname);
		
		g_iOwner[iProp] = iClient;
		
		CM_AddToPropCount(iClient);
		
		g_bCMEntity[iProp] = true;
		
		g_bCanCopy[iProp] = true;
	}
	
	return Plugin_Handled;
}

public Action Command_Straight(int iClient, int iArgs)
{
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		TeleportEntity(iEntity, NULL_VECTOR, g_fZero, NULL_VECTOR);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StartCopy(int iClient, int iArgs)
{
	char sModel[128], sPropname[64], sSkin[64];
	float fAngles[3], fClientAngles[3], fClientOrigin[3], fOrigin[3];
	int iColor[4], iSolid;
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (CM_CheckPropCount(iClient))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You have reached the max prop limit.");
		return Plugin_Handled;
	}
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (!g_bCanCopy[iEntity])
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You cannot copy this entity!");
		return Plugin_Handled;
	}
	
	if (g_iCopyEnt[iClient] != -1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You are already copying something!");
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		IntToString(GetEntProp(iEntity, Prop_Data, "m_nSkin", 1), sSkin, sizeof(sSkin));
		iSolid = GetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 4, 0);
		
		GetEntityRenderColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
		
		CM_GetPropName(iEntity, sPropname);
		
		CM_GetEntityAngles(iEntity, fAngles);
		CM_GetEntityOrigin(iEntity, fOrigin);
		
		GetClientAbsAngles(iClient, fClientAngles);
		GetClientAbsOrigin(iClient, fClientOrigin);
		
		int iCopyEnt = CreateEntityByName("prop_physics_override");
		
		PrecacheModel(sModel);
		
		DispatchKeyValue(iCopyEnt, "model", sModel);
		DispatchKeyValue(iCopyEnt, "skin", sSkin);
		
		DispatchSpawn(iCopyEnt);
		
		CM_SetEntityColor(iCopyEnt, iColor[0], iColor[1], iColor[2], iColor[3]);
		
		SetEntityRenderColor(iCopyEnt, 0, 0, 255, 128);
		SetEntityRenderFx(iCopyEnt, RENDERFX_DISTORT);
		
		TeleportEntity(iCopyEnt, fOrigin, fAngles, NULL_VECTOR);
		
		g_fCopyOrigin[iClient][0] = fOrigin[0] - fClientOrigin[0];
		g_fCopyOrigin[iClient][1] = fOrigin[1] - fClientOrigin[1];
		g_fCopyOrigin[iClient][2] = fOrigin[2] - fClientOrigin[2];
		
		CM_SetPropName(iCopyEnt, sPropname);
		
		SetEntProp(iCopyEnt, Prop_Send, "m_CollisionGroup", iSolid);
		
		AcceptEntityInput(iCopyEnt, "disablemotion");
		
		g_iOwner[iCopyEnt] = iClient;
		
		CM_AddToPropCount(iClient);
		
		g_bCMEntity[iCopyEnt] = true;
		
		g_bCanCopy[iCopyEnt] = true;
		
		g_iCopyEnt[iClient] = iCopyEnt;
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StartGrab(int iClient, int iArgs)
{
	float fOrigin[3], fEntityOrigin[3];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (g_iGrabEnt[iClient] != -1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You are already grabbing something!");
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		GetClientAbsOrigin(iClient, fOrigin);
		CM_GetEntityOrigin(iEntity, fEntityOrigin);
		
		g_fGrabOrigin[iClient][0] = fEntityOrigin[0] - fOrigin[0];
		g_fGrabOrigin[iClient][1] = fEntityOrigin[1] - fOrigin[1];
		g_fGrabOrigin[iClient][2] = fEntityOrigin[2] - fOrigin[2];
		
		SetEntityRenderColor(iEntity, 0, 255, 0, 128);
		SetEntityRenderFx(iEntity, RENDERFX_DISTORT);
		
		g_iGrabEnt[iClient] = iEntity;
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StopCopy(int iClient, int iArgs)
{
	if (g_iCopyEnt[iClient] == -1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You aren't copying something!");
		return Plugin_Handled;
	}
	
	if (g_iCopyEnt[iClient] != -1)
	{
		SetEntityRenderColor(g_iCopyEnt[iClient], g_iColor[g_iCopyEnt[iClient]][0], g_iColor[g_iCopyEnt[iClient]][1], g_iColor[g_iCopyEnt[iClient]][2], g_iColor[g_iCopyEnt[iClient]][3]);
		SetEntityRenderFx(g_iCopyEnt[iClient], RENDERFX_NONE);
		
		g_fCopyOrigin[iClient] = g_fZero;
		
		g_iCopyEnt[iClient] = -1;
	}
	
	return Plugin_Handled;
}

public Action Command_StopGrab(int iClient, int iArgs)
{
	if (g_iGrabEnt[iClient] == -1)
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} You aren't grabbing something!");
		return Plugin_Handled;
	}
	
	if (g_iGrabEnt[iClient] != -1)
	{
		SetEntityRenderColor(g_iGrabEnt[iClient], g_iColor[g_iGrabEnt[iClient]][0], g_iColor[g_iGrabEnt[iClient]][1], g_iColor[g_iGrabEnt[iClient]][2], g_iColor[g_iGrabEnt[iClient]][3]);
		SetEntityRenderFx(g_iGrabEnt[iClient], RENDERFX_NONE);
		
		g_fGrabOrigin[iClient] = g_fZero;
		
		g_iGrabEnt[iClient] = -1;
	}
	
	return Plugin_Handled;
}

public Action Command_UnFreeze(int iClient, int iArgs)
{
	char sClassname[64];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCMEntity[iEntity])
	{
		CM_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (CM_CheckOwner(iClient, iEntity))
	{
		GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
		
		if (StrContains(sClassname, "prop_door_rotating") != -1)
		{
			CPrintToChat(iClient, "{blue}|CelMod|{default} Door has been unlocked.");
			
			AcceptEntityInput(iEntity, "lock");
		} else {
			CPrintToChat(iClient, "{blue}|CelMod|{default} Enabled motion on %s object.", StrContains(sClassname, "prop_") != -1 ? "prop" : "cel");
			
			AcceptEntityInput(iEntity, "enablemotion");
		}
		
		CM_ChangeBeam(iClient, iEntity);
	} else {
		CM_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public void CM_AddToCelCount(int iClient)
{
	int iCount = CM_GetCelCount(iClient);
	
	iCount++;
	
	CM_SetCelCount(iClient, iCount);
}

public void CM_AddToPropCount(int iClient)
{
	int iCount = CM_GetPropCount(iClient);
	
	iCount++;
	
	CM_SetPropCount(iClient, iCount);
}

public void CM_ChangeBeam(int iClient, int iEntity)
{
	char sSound[96];
	
	float fClientOrigin[3], fEntityOrigin[3];
	
	GetClientAbsOrigin(iClient, fClientOrigin);
	
	CM_GetEntityOrigin(iEntity, fEntityOrigin);
	
	TE_SetupBeamPoints(fClientOrigin, fEntityOrigin, g_iPhys, g_iHalo, 0, 15, 0.25, 5.0, 5.0, 1, 0.0, g_iWhite, 10); TE_SendToAll();
	TE_SetupSparks(fEntityOrigin, NULL_VECTOR, 2, 5); TE_SendToAll();
	
	Format(sSound, sizeof(sSound), "weapons/airboat/airboat_gun_lastshot%i.wav", GetRandomInt(1, 2));
	
	PrecacheSound(sSound);
	
	EmitSoundToAll(sSound, iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

public bool CM_CheckCelCount(int iClient)
{
	int iCount, iLimit;
	
	iCount = CM_GetCelCount(iClient);
	iLimit = CM_GetCelLimit();
	
	if (iCount >= iLimit)
	{
		return true;
	}
	
	return false;
}

public bool CM_CheckOwner(int iClient, int iEntity)
{
	if (g_iOwner[iEntity] == iClient)
	{
		return true;
	}
	
	return false;
}

public bool CM_CheckPropCount(int iClient)
{
	int iCount, iLimit;
	
	iCount = CM_GetPropCount(iClient);
	iLimit = CM_GetPropLimit();
	
	if (iCount >= iLimit)
	{
		return true;
	}
	
	return false;
}

public void CM_ChooseColor(int iClient)
{
	switch (GetRandomInt(0, 6))
	{
		case 0:
		{
			g_iClientColor[iClient] = g_iRed;
		}
		case 1:
		{
			g_iClientColor[iClient] = g_iOrange;
		}
		case 2:
		{
			g_iClientColor[iClient] = g_iYellow;
		}
		case 3:
		{
			g_iClientColor[iClient] = g_iGreen;
		}
		case 4:
		{
			g_iClientColor[iClient] = g_iBlue;
		}
		case 5:
		{
			g_iClientColor[iClient] = g_iWhite;
		}
		case 6:
		{
			g_iClientColor[iClient] = g_iGray;
		}
	}
}

public void CM_ConVarChanged(ConVar hConVar, const char[] sOldValue, const char[] sNewValue)
{
	CM_SetCelLimit(GetConVarInt(g_hCelLimit));
	CM_SetPropLimit(GetConVarInt(g_hPropLimit));
}

public void CM_DissolveEntity(int iEntity)
{
	DispatchKeyValue(iEntity, "targetname", "dissolved");
	
	AcceptEntityInput(g_iEntityDissolver, "dissolve");
}

public void CM_DownloadFiles()
{
	Handle hDownloadFiles = OpenFile(g_sDownloadDB, "r");
	
	char sBuffer[256];
	
	while (ReadFileLine(hDownloadFiles, sBuffer, sizeof(sBuffer)))
	{
		int iLen = strlen(sBuffer);
		
		if (sBuffer[iLen - 1] == '\n')
		{
			sBuffer[--iLen] = '\0';
		}
		
		if (FileExists(sBuffer))
		{
			AddFileToDownloadsTable(sBuffer);
		}
		
		if (StrContains(sBuffer, ".mdl", false) != -1)
		{
			PrecacheModel(sBuffer, true);
		}
		
		if (IsEndOfFile(hDownloadFiles))
		{
			break;
		}
	}
}

public void CM_DrawLand(float fFrom[3], float fTo[3], float fLife, int iColor[4], bool bFlat)
{
	float fLeftBottomFront[3];
	
	fLeftBottomFront[0] = fFrom[0];
	fLeftBottomFront[1] = fFrom[1];
	
	if (bFlat)
	{
		fLeftBottomFront[2] = fTo[2] - 2;
	} else {
		fLeftBottomFront[2] = fTo[2];
	}
	
	float fRightBottomFront[3];
	
	fRightBottomFront[0] = fTo[0];
	fRightBottomFront[1] = fFrom[1];
	
	if (bFlat)
	{
		fRightBottomFront[2] = fTo[2] - 2;
	} else {
		fRightBottomFront[2] = fTo[2];
	}
	
	float fLeftBottomBack[3];
	
	fLeftBottomBack[0] = fFrom[0];
	fLeftBottomBack[1] = fTo[1];
	
	if (bFlat)
	{
		fLeftBottomBack[2] = fTo[2] - 2;
	} else {
		fLeftBottomBack[2] = fTo[2];
	}
	
	float fRightBottomBack[3];
	
	fRightBottomBack[0] = fTo[0];
	fRightBottomBack[1] = fTo[1];
	
	if (bFlat)
	{
		fRightBottomBack[2] = fTo[2] - 2;
	} else {
		fRightBottomBack[2] = fTo[2];
	}
	
	float fLeftTopFront[3];
	
	fLeftTopFront[0] = fFrom[0];
	fLeftTopFront[1] = fFrom[1];
	
	if (bFlat)
	{
		fLeftTopFront[2] = fFrom[2] + 3;
	} else {
		fLeftTopFront[2] = fFrom[2] + 100;
	}
	
	float fRightTopFront[3];
	
	fRightTopFront[0] = fTo[0];
	fRightTopFront[1] = fFrom[1];
	
	if (bFlat)
	{
		fRightTopFront[2] = fFrom[2] + 3;
	} else {
		fRightTopFront[2] = fFrom[2] + 100;
	}
	
	float fLeftTopBack[3];
	
	fLeftTopBack[0] = fFrom[0];
	fLeftTopBack[1] = fTo[1];
	
	if (bFlat)
	{
		fLeftTopBack[2] = fFrom[2] + 3;
	} else {
		fLeftTopBack[2] = fFrom[2] + 100;
	}
	
	float fRightTopBack[3];
	
	fRightTopBack[0] = fTo[0];
	fRightTopBack[1] = fTo[1];
	
	if (bFlat)
	{
		fRightTopBack[2] = fFrom[2] + 3;
	} else {
		fRightTopBack[2] = fFrom[2] + 100;
	}
	
	TE_SetupBeamPoints(fLeftTopFront, fRightTopFront, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	TE_SetupBeamPoints(fLeftTopFront, fLeftTopBack, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightTopBack, fLeftTopBack, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightTopBack, fRightTopFront, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	
	/*if (!bFlat)
	{
		TE_SetupBeamPoints(fLeftBottomFront, fRightBottomFront, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
		TE_SetupBeamPoints(fLeftBottomFront, fLeftBottomBack, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
		TE_SetupBeamPoints(fLeftBottomFront, fLeftTopFront, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
		
		
		TE_SetupBeamPoints(fRightBottomBack, fLeftBottomBack, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
		TE_SetupBeamPoints(fRightBottomBack, fRightBottomFront, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
		TE_SetupBeamPoints(fRightBottomBack, fRightTopBack, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
		
		TE_SetupBeamPoints(fRightBottomFront, fRightTopFront, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
		TE_SetupBeamPoints(fLeftBottomBack, fLeftTopBack, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	}*/
}

public bool CM_FilterPlayer(int iEntity, any iContentsMask)
{
	return iEntity > MaxClients;
}

public char CM_GetAuthID(int iClient, char sAuthID[64])
{
	strcopy(sAuthID, sizeof(sAuthID), g_sAuthID[iClient]);
}

public int CM_GetCelCount(int iClient)
{
	return g_iCelCount[iClient];
}

public int CM_GetCelLimit()
{
	return g_iCelLimit;
}

public int CM_GetClientAimEntity(int iClient)
{
	float fEyeAngles[3], fEyeOrigin[3];
	
	GetClientEyeAngles(iClient, fEyeAngles);
	GetClientEyePosition(iClient, fEyeOrigin);
	
	Handle hTraceRay = TR_TraceRayFilterEx(fEyeOrigin, fEyeAngles, MASK_SOLID, RayType_EndPoint, CM_FilterPlayer);
	
	if (TR_DidHit(hTraceRay))
	{
		int iEntity = TR_GetEntityIndex(hTraceRay);
		
		CloseHandle(hTraceRay);
		
		return iEntity;
	} else {
		return -1;
	}
}

public float CM_GetEndPoint(int iClient, float fFinalOrigin[3])
{
	float fEyeAngles[3], fEyeOrigin[3];
	
	GetClientEyeAngles(iClient, fEyeAngles);
	GetClientEyePosition(iClient, fEyeOrigin);
	
	Handle hTraceRay = TR_TraceRayFilterEx(fEyeOrigin, fEyeAngles, MASK_ALL, RayType_Infinite, CM_FilterPlayer);
	
	if (TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(fFinalOrigin, hTraceRay);
		
		CloseHandle(hTraceRay);
	}
}

public float CM_GetEntityAngles(int iEntity, float fAngles[3])
{
	GetEntPropVector(iEntity, Prop_Send, "m_angRotation", fAngles);
}

public int CM_GetEntityColor(int iEntity, int iR, int iG, int iB, int iA)
{
	g_iColor[iEntity][0] = iR, g_iColor[iEntity][1] = iG, g_iColor[iEntity][2] = iB, g_iColor[iEntity][3] = iA;
}

public bool CM_GetGodMode(int iClient)
{
	return g_bGodMode[iClient];
}

public float CM_GetEntityOrigin(int iEntity, float fOrigin[3])
{
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fOrigin);
}

public char CM_GetInternetURL(int iEntity, char sInternetURL[256])
{
	strcopy(sInternetURL, sizeof(sInternetURL), g_sInternetURL[iEntity]);
}

public float CM_GetMiddleOfBox(const float fMin[3], const float fMax[3], float fMiddle[3])
{
	float fMid[3];
	
	MakeVectorFromPoints(fMin, fMax, fMid);
	
	fMid[0] = fMid[0] / 2.0;
	fMid[1] = fMid[1] / 2.0;
	fMid[2] = fMid[2] / 2.0;
	
	AddVectors(fMin, fMid, fMiddle);
}

public int CM_GetPropCount(int iClient)
{
	return g_iPropCount[iClient];
}

public int CM_GetPropLimit()
{
	return g_iPropLimit;
}

public char CM_GetPropName(int iEntity, char sPropName[64])
{
	strcopy(sPropName, sizeof(sPropName), g_sPropName[iEntity]);
}

/*bool CM_IsClientInsideArea(float fSource[3], float fPoint1[3], float fPoint2[3], int iClient = 0)
{
	bool bIsX, bIsY, bIsZ;
	
	if (fPoint1[0] > fPoint2[0] && fSource[0] <= fPoint1[0] && fSource[0] >= fPoint2[0])
		bIsX = true;
	else if (fPoint1[0] < fPoint2[0] && fSource[0] >= fPoint1[0] && fSource[0] <= fPoint2[0])
		bIsX = true;
	
	if (fPoint1[1] > fPoint2[1] && fSource[1] <= fPoint1[1] && fSource[1] >= fPoint2[1])
		bIsY = true;
	else if (fPoint1[1] < fPoint2[1] && fSource[1] >= fPoint1[1] && fSource[1] <= fPoint2[1])
		bIsY = true;
	
	if (iClient == 0)
	{
		if (fSource[2] <= fPoint1[2] + 250 && fSource[2] >= fPoint2[2])
			bIsZ = true;
		else if (fSource[2] >= fPoint1[2] + 250 && fSource[2] <= fPoint2[2])
			bIsZ = true;
	} else
	{
		if (fSource[2] <= fPoint1[2] + fPoint2[1] && fSource[2] >= (fPoint2[2] + 500))
			bIsZ = true;
		else if (fSource[2] >= fPoint1[2] + fPoint2[1] && fSource[2] <= (fPoint2[2] + 500))
			bIsZ = true;
	}
	
	if (bIsX && bIsY && bIsZ)return true;
	
	return false;
}*/

bool CM_IsClientInsideArea(float fPCords[3], float fbsx, float fbsy, float fbsz, float fbex, float fbey, float fbez)
{
	float fpx = fPCords[0];
	float fpy = fPCords[1];
	float fpz = fPCords[2];
	
	bool bX = false;
	bool bY = false;
	bool bZ = false;
	
	if (fbsx > fbex && fpx <= fbsx && fpx >= fbex)
	{
		bX = true;
	}
	else if (fbsx < fbex && fpx >= fbsx && fpx <= fbex)
	{
		bX = true;
	}
	
	if (fbsy > fbey && fpy <= fbsy && fpy >= fbey)
	{
		bY = true;
	}
	else if (fbsy < fbey && fpy >= fbsy && fpy <= fbey)
	{
		bY = true;
	}
	
	if (fbsz > fbez && fpz <= fbsz && fpz >= fbez)
	{
		bZ = true;
	}
	else if (fbsz < fbez && fpz >= fbsz && fpz <= fbez)
	{
		bZ = true;
	}
	
	if (bX && bY && bZ)
	{
		return true;
	}
	
	return false;
}

int CM_IsClientInsideLand(int iClient)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (!g_bLandDrawing[i])continue;
		
		if (iClient != 0)
		{
			float fClientO[3];
			GetClientAbsOrigin(iClient, fClientO);
			
			if (CM_IsClientInsideArea(fClientO, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2]))return i;
		} else {
			//if(CM_IsClientInsideArea(fSource, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2])) return i;
		}
	}
	
	return -1;
}

int CM_IsCrosshairInsideLand(int iClient)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (!g_bLandDrawing[i])continue;
		
		if (iClient != 0)
		{
			float fOrigin[3];
			CM_GetEndPoint(iClient, fOrigin);
			
			if (CM_IsClientInsideArea(fOrigin, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2]))return i;
		} else {
			//if(CM_IsClientInsideArea(fSource, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2])) return i;
		}
	}
	
	return -1;
}

int CM_IsEntityInsideLand(int iEntity)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (!g_bLandDrawing[i])continue;
		
		if (iEntity != -1 && g_bCMEntity[iEntity])
		{
			float fEntityO[3];
			CM_GetEntityOrigin(iEntity, fEntityO);
			
			if (CM_IsClientInsideArea(fEntityO, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2]))return i;
		} else {
			//if(CM_IsClientInsideArea(fSource, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2])) return i;
		}
	}
	
	return -1;
}

public void CM_LoadBuild(int iClient, char[] sBuildname)
{
	bool bLoop = false;
	char sFile[PLATFORM_MAX_PATH], sClassname[128], sModel[256], sSkin[64], sSolid[64], sAlias[128], sSound[256], sMusic[256], sURL[256], sPropCount[64];
	float fAngles[3], fEntityOrigin[3], fFinalOrigin[3], fMusicTime, fOrigin[3];
	int iColor[4], iLoop;
	
	BuildPath(Path_SM, sFile, sizeof(sFile), "data/celmod/saves/%s/%s.txt", g_sAuthID[iClient], sBuildname);
	if (FileExists(sFile))
	{
		DeleteFile(sFile);
		
		CreateDirectory(sFile, 511);
		
		KeyValues hLoad = CreateKeyValues(sBuildname);
		
		FileToKeyValues(hLoad, sFile);
		
		KvJumpToKey(hLoad, "propcount");
		
		int iPropCount = KvGetNum(hLoad, "propcount");
		
		for (int i = 0; i < iPropCount; i++)
		{
			IntToString(i, sPropCount, sizeof(sPropCount));
			
			if (KvJumpToKey(hLoad, sPropCount, false))
			{
				KvGetString(hLoad, "classname", sClassname, sizeof(sClassname));
				
				KvGetString(hLoad, "model", sModel, sizeof(sModel));
				
				KvGetString(hLoad, "skin", sSkin, sizeof(sSkin));
				KvGetString(hLoad, "solid", sSolid, sizeof(sSolid));
				
				fEntityOrigin[0] = KvGetFloat(hLoad, "o1");
				fEntityOrigin[1] = KvGetFloat(hLoad, "o2");
				fEntityOrigin[2] = KvGetFloat(hLoad, "o3");
				
				fAngles[0] = KvGetFloat(hLoad, "a1");
				fAngles[1] = KvGetFloat(hLoad, "a2");
				fAngles[2] = KvGetFloat(hLoad, "a3");
				
				iColor[0] = KvGetNum(hLoad, "r");
				iColor[1] = KvGetNum(hLoad, "g");
				iColor[2] = KvGetNum(hLoad, "b");
				iColor[3] = KvGetNum(hLoad, "a");
				
				CM_GetEndPoint(iClient, fOrigin);
				
				fFinalOrigin[0] = fEntityOrigin[0] + fOrigin[0];
				fFinalOrigin[1] = fEntityOrigin[1] + fOrigin[1];
				fFinalOrigin[2] = fEntityOrigin[2] + fOrigin[2];
				
				if (StrEqual(sClassname, "cel_door"))
				{
					KvGetString(hLoad, "alias", sAlias, sizeof(sAlias));
					
					int iEntity = CreateEntityByName("prop_door_rotating");
					
					PrecacheModel(sModel);
					
					DispatchKeyValue(iEntity, "classname", "cel_door");
					DispatchKeyValue(iEntity, "model", sModel);
					DispatchKeyValue(iEntity, "distance", "90");
					DispatchKeyValue(iEntity, "hardware", "1");
					DispatchKeyValue(iEntity, "returndelay", "5");
					DispatchKeyValue(iEntity, "skin", sSkin);
					DispatchKeyValue(iEntity, "spawnflags", "8192");
					DispatchKeyValue(iEntity, "speed", "100");
					
					DispatchSpawn(iEntity);
					
					TeleportEntity(iEntity, fFinalOrigin, fAngles, NULL_VECTOR);
					
					g_iOwner[iEntity] = iClient;
					
					CM_AddToCelCount(iClient);
					
					CM_SetEntityColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
					
					CM_SetPropName(iEntity, sAlias);
					
					g_bCMEntity[iEntity] = true;
					
					g_bFadeColor[iEntity] = false;
				} else if (StrEqual(sClassname, "cel_internet"))
				{
					KvGetString(hLoad, "url", sURL, sizeof(sURL));
					
					int iEntity = CreateEntityByName("prop_physics_override");
					
					PrecacheModel(sModel);
					
					DispatchKeyValue(iEntity, "classname", "cel_internet");
					DispatchKeyValue(iEntity, "model", sModel);
					
					DispatchSpawn(iEntity);
					
					TeleportEntity(iEntity, fFinalOrigin, fAngles, NULL_VECTOR);
					
					DispatchKeyValue(iEntity, "skin", sSkin);
					
					CM_SetInternetURL(iEntity, sURL);
					
					g_iOwner[iEntity] = iClient;
					
					CM_AddToCelCount(iClient);
					
					CM_SetEntityColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
					
					AcceptEntityInput(iEntity, "disablemotion");
					
					g_bCMEntity[iEntity] = true;
					
					g_bFadeColor[iEntity] = false;
					
					g_bCanCopy[iEntity] = false;
				} else if (StrEqual(sClassname, "cel_music"))
				{
					KvGetString(hLoad, "alias", sAlias, sizeof(sAlias));
					
					KvGetString(hLoad, "music", sMusic, sizeof(sMusic));
					
					fMusicTime = KvGetFloat(hLoad, "musictime");
					
					iLoop = KvGetNum(hLoad, "loop");
					int iEntity = CreateEntityByName("prop_physics_override");
					
					PrecacheModel(sModel);
					
					DispatchKeyValue(iEntity, "classname", "cel_music");
					DispatchKeyValue(iEntity, "model", sModel);
					
					DispatchSpawn(iEntity);
					
					TeleportEntity(iEntity, fFinalOrigin, fAngles, NULL_VECTOR);
					
					Format(g_sMusic[iEntity], sizeof(g_sMusic[]), sMusic);
					
					g_fMusicTime[iEntity] = fMusicTime;
					
					g_iOwner[iEntity] = iClient;
					
					CM_AddToCelCount(iClient);
					
					CM_SetEntityColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
					
					CM_SetPropName(iEntity, sAlias);
					
					AcceptEntityInput(iEntity, "disablemotion");
					
					g_bCMEntity[iEntity] = true;
					
					g_bFadeColor[iEntity] = false;
					
					g_bCanCopy[iEntity] = false;
					
					if (iLoop == 1)
					{
						bLoop = true;
					} else {
						bLoop = false;
					}
					
					g_bLoop[iEntity] = bLoop;
				} else if (StrEqual(sClassname, "prop_physics"))
				{
					KvGetString(hLoad, "alias", sAlias, sizeof(sAlias));
					
					int iEntity = CreateEntityByName("prop_physics_override");
					
					PrecacheModel(sModel);
					
					DispatchKeyValue(iEntity, "classname", "prop_physics");
					DispatchKeyValue(iEntity, "model", sModel);
					
					DispatchSpawn(iEntity);
					
					TeleportEntity(iEntity, fFinalOrigin, fAngles, NULL_VECTOR);
					
					g_iOwner[iEntity] = iClient;
					
					CM_AddToPropCount(iClient);
					
					CM_SetEntityColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
					
					AcceptEntityInput(iEntity, "disablemotion");
					
					CM_SetPropName(iEntity, sAlias);
					
					g_bCMEntity[iEntity] = true;
					
					g_bFadeColor[iEntity] = false;
					
					g_bCanCopy[iEntity] = true;
				} else if (StrEqual(sClassname, "cel_sound"))
				{
					KvGetString(hLoad, "alias", sAlias, sizeof(sAlias));
					
					KvGetString(hLoad, "sound", sSound, sizeof(sSound));
					
					int iEntity = CreateEntityByName("prop_physics_override");
					
					PrecacheModel(sModel);
					
					DispatchKeyValue(iEntity, "classname", "cel_sound");
					DispatchKeyValue(iEntity, "model", sSound);
					
					DispatchSpawn(iEntity);
					
					TeleportEntity(iEntity, fFinalOrigin, fAngles, NULL_VECTOR);
					
					Format(g_sSound[iEntity], sizeof(g_sSound[]), sSound);
					
					g_iOwner[iEntity] = iClient;
					
					CM_AddToCelCount(iClient);
					
					CM_SetEntityColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
					
					CM_SetPropName(iEntity, sAlias);
					
					AcceptEntityInput(iEntity, "disablemotion");
					
					g_bCMEntity[iEntity] = true;
					
					g_bFadeColor[iEntity] = false;
					
					g_bCanCopy[iEntity] = false;
				}
			}
		}
		
		CloseHandle(hLoad);
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} Loaded building.");
	} else {
		CPrintToChat(iClient, "{blue}|CelMod|{default} Build {green}%s{default} doesn't exist!", sBuildname);
		
		CreateDirectory(sFile, 511);
	}
}

public void CM_LoadClientBalance(int iClient)
{
	KeyValues hBalance = CreateKeyValues("Balance");
	
	FileToKeyValues(hBalance, g_sBalanceDB);
	
	if (KvJumpToKey(hBalance, g_sAuthID[iClient], false))
	{
		g_iBalance[iClient] = KvGetNum(hBalance, "balance", 0);
	} else {
		KvJumpToKey(hBalance, g_sAuthID[iClient], true);
		
		g_iBalance[iClient] = KvGetNum(hBalance, "balance", 0);
	}
	
	CloseHandle(hBalance);
}

public void CM_NotLooking(int iClient)
{
	CPrintToChat(iClient, "{blue}|CelMod|{default} You are not looking at anything!");
}

public void CM_NotYours(int iClient)
{
	CPrintToChat(iClient, "{blue}|CelMod|{default} That doesn't belong to you!");
}

public void CM_RemovalBeam(int iClient, int iEntity)
{
	char sSound[96];
	
	float fClientOrigin[3], fEntityOrigin[3];
	
	GetClientAbsOrigin(iClient, fClientOrigin);
	
	CM_GetEntityOrigin(iEntity, fEntityOrigin);
	
	TE_SetupBeamPoints(fClientOrigin, fEntityOrigin, g_iBeam, g_iHalo, 0, 15, 0.25, 5.0, 5.0, 1, 0.0, g_iGray, 10); TE_SendToAll();
	
	TE_SetupBeamRingPoint(fEntityOrigin, 0.0, 15.0, g_iBeam, g_iHalo, 0, 15, 0.5, 5.0, 0.0, g_iGray, 10, 0); TE_SendToAll();
	
	Format(sSound, sizeof(sSound), "ambient/levels/citadel/weapon_disintegrate%i.wav", GetRandomInt(1, 4));
	
	PrecacheSound(sSound);
	
	EmitAmbientSound(sSound, fEntityOrigin, iEntity, 100, 0, 1.0, 100, 0.0);
}

public void CM_RemoveMapProtection()
{
	char sName[128];
	
	int iRealMaxEntities = GetMaxEntities() * 2;
	
	for (int i = 0; i < iRealMaxEntities; i++)
	{
		if (!IsValidEntity(i))
		{
			continue;
		}
		
		GetEntPropString(i, Prop_Data, "m_iName", sName, sizeof(sName));
		
		if (StrEqual(sName, "point_servercommand") || StrEqual(sName, "MAP_PROTECTION_COMMAND"))
		{
			AcceptEntityInput(i, "kill");
		}
	}
}

public void CM_SaveBuild(int iClient, char[] sBuildname)
{
	char sCount[64], sFile[PLATFORM_MAX_PATH], sModelName[128], sClassname[64], sPropname[64], sSkin[64], sSolid[64];
	float fMiddle[3], fAngles[3], fEntityOrigin[3], fOrigin[3];
	int iColor[4];
	
	BuildPath(Path_SM, sFile, sizeof(sFile), "data/celmod/saves/%s/%s.txt", g_sAuthID[iClient], sBuildname);
	
	if (FileExists(sFile))
	{
		CPrintToChat(iClient, "{blue}|CelMod|{default} Build {green}%s{default} already exists! It will be over-written!", sBuildname);
		
		DeleteFile(sFile);
		
		BuildPath(Path_SM, sFile, sizeof(sFile), "data/celmod/saves/%s/%s.txt", g_sAuthID[iClient], sBuildname);
		
		File fFile = OpenFile(sFile, "a+");
				
		FlushFile(fFile);
		
		fFile.Close();
	}else{
		BuildPath(Path_SM, sFile, sizeof(sFile), "data/celmod/saves/%s/%s.txt", g_sAuthID[iClient], sBuildname);
		
		File fFile = OpenFile(sFile, "a+");
				
		FlushFile(fFile);
		
		fFile.Close();
	}
	
	KeyValues kvSave = new KeyValues(sBuildname);
	
	kvSave.ImportFromFile(sFile);
	
	int iCount = 0;
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (CM_CheckOwner(iClient, i))
		{
			int iLand = CM_IsEntityInsideLand(i);
			
			if (iLand != -1)
			{
				iCount++;
				
				GetEdictClassname(i, sClassname, sizeof(sClassname));
				
				GetEntPropString(i, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
				
				IntToString(GetEntProp(i, Prop_Data, "m_nSkin", 1), sSkin, sizeof(sSkin));
				IntToString(GetEntProp(i, Prop_Send, "m_CollisionGroup", 4, 0), sSolid, sizeof(sSolid));
				
				GetEntityRenderColor(i, iColor[0], iColor[1], iColor[2], iColor[3]);
				
				CM_GetPropName(i, sPropname);
				
				CM_GetMiddleOfBox(g_fLandOrigin[iClient][0], g_fLandOrigin[iClient][1], fMiddle);
				
				fMiddle[2] = g_fLandOrigin[iClient][0][2];
				
				CM_GetEntityAngles(i, fAngles);
				CM_GetEntityOrigin(i, fEntityOrigin);
				
				fOrigin[0] = fEntityOrigin[0] - fMiddle[0];
				fOrigin[1] = fEntityOrigin[1] - fMiddle[1];
				fOrigin[2] = fEntityOrigin[2] - fMiddle[2];
				
				IntToString(iCount, sCount, sizeof(sCount));
				
				kvSave.JumpToKey(sCount, true);
				
				kvSave.SetString("classname", sClassname);
				kvSave.SetString("model", sModelName);
				
				kvSave.SetString("skin", sSkin);
				kvSave.SetString("solid", sSolid);
				
				kvSave.SetFloat("o1", fOrigin[0]);
				kvSave.SetFloat("o2", fOrigin[1]);
				kvSave.SetFloat("o3", fOrigin[2]);
				
				kvSave.SetFloat("a1", fAngles[0]);
				kvSave.SetFloat("a2", fAngles[1]);
				kvSave.SetFloat("a3", fAngles[2]);
				
				kvSave.SetNum("r", iColor[0]);
				kvSave.SetNum("g", iColor[1]);
				kvSave.SetNum("b", iColor[2]);
				kvSave.SetNum("a", iColor[3]);
				
				if (StrEqual(sClassname, "cel_internet"))
				{
					kvSave.SetString("url", g_sInternetURL[i]);
				} else if (StrEqual(sClassname, "cel_music"))
				{
					kvSave.SetString("alias", sPropname);
					kvSave.SetString("music", g_sMusic[i]);
					kvSave.SetFloat("musictime", g_fMusicTime[i]);
					kvSave.SetNum("loop", g_bLoop[i] ? 1 : 0);
				} else if (StrEqual(sClassname, "cel_sound"))
				{
					kvSave.SetString("alias", sPropname);
					kvSave.SetString("sound", g_sSound[i]);
				} else {
					kvSave.SetString("alias", sPropname);
				}
			}
			kvSave.Rewind();
		}
	}
	
	kvSave.JumpToKey("propcount", true);
	
	kvSave.SetNum("propcount", iCount);
	
	kvSave.Rewind();
	
	kvSave.ExportToFile(sFile);
	
	kvSave.Close();
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} Saved {green}%i{default} props to {green}%s{default}.", iCount, sBuildname);
}

public void CM_SaveClientBalance(int iClient)
{
	KeyValues hBalance = CreateKeyValues("Balance");
	
	FileToKeyValues(hBalance, g_sBalanceDB);
	
	if (KvJumpToKey(hBalance, g_sAuthID[iClient], false))
	{
		KvSetNum(hBalance, "balance", g_iBalance[iClient]);
	} else {
		KvJumpToKey(hBalance, g_sAuthID[iClient], true);
		
		KvSetNum(hBalance, "balance", g_iBalance[iClient]);
	}
	
	KeyValuesToFile(hBalance, g_sBalanceDB);
	
	CloseHandle(hBalance);
}

public void CM_SendHudMessage(int iClient, int iChannel, 
	float fX, float fY, 
	int iR, int iG, int iB, int iA, 
	int iEffect, 
	float fFadeIn, float fFadeOut, 
	float fHoldTime, float fFxTime, 
	char[] sMessage)
{
	Handle hHudMessage;
	if (!iClient)
	{
		hHudMessage = StartMessageAll("HudMsg");
	} else {
		hHudMessage = StartMessageOne("HudMsg", iClient);
	}
	if (hHudMessage != INVALID_HANDLE)
	{
		BfWriteByte(hHudMessage, iChannel);
		BfWriteFloat(hHudMessage, fX);
		BfWriteFloat(hHudMessage, fY);
		BfWriteByte(hHudMessage, iR);
		BfWriteByte(hHudMessage, iG);
		BfWriteByte(hHudMessage, iB);
		BfWriteByte(hHudMessage, iA);
		BfWriteByte(hHudMessage, iR);
		BfWriteByte(hHudMessage, iG);
		BfWriteByte(hHudMessage, iB);
		BfWriteByte(hHudMessage, iA);
		BfWriteByte(hHudMessage, iEffect);
		BfWriteFloat(hHudMessage, fFadeIn);
		BfWriteFloat(hHudMessage, fFadeOut);
		BfWriteFloat(hHudMessage, fHoldTime);
		BfWriteFloat(hHudMessage, fFxTime);
		BfWriteString(hHudMessage, sMessage);
		EndMessage();
	}
}

public void CM_SetAuthID(int iClient)
{
	GetClientAuthId(iClient, AuthId_Steam2, g_sAuthID[iClient], sizeof(g_sAuthID[]));
	
	ReplaceString(g_sAuthID[iClient], sizeof(g_sAuthID[]), ":", "_");
}

public void CM_SetCelCount(int iClient, int iCount)
{
	g_iCelCount[iClient] = iCount;
}

public void CM_SetCelLimit(int iLimit)
{
	g_iCelLimit = iLimit;
}

public void CM_SetEntityColor(int iEntity, int iR, int iG, int iB, int iA)
{
	SetEntityRenderColor(iEntity, iR, iG, iB, iA);
	
	g_iColor[iEntity][0] = iR, g_iColor[iEntity][1] = iG, g_iColor[iEntity][2] = iB, g_iColor[iEntity][3] = iA;
}

public void CM_SetGodMode(int iClient, bool bGodMode)
{
	if (bGodMode)
	{
		SetEntProp(iClient, Prop_Data, "m_takedamage", 0, 1);
	} else {
		SetEntProp(iClient, Prop_Data, "m_takedamage", 2, 1);
	}
	
	g_bGodMode[iClient] = bGodMode;
}

public void CM_SetInternetURL(int iEntity, const char[] sURL)
{
	Format(g_sInternetURL[iEntity], sizeof(g_sInternetURL[]), sURL);
}

public void CM_SetPropCount(int iClient, int iCount)
{
	g_iPropCount[iClient] = iCount;
}

public void CM_SetPropLimit(int iLimit)
{
	g_iPropLimit = iLimit;
}

public void CM_SetPropName(int iEntity, const char[] sPropName)
{
	Format(g_sPropName[iEntity], sizeof(g_sPropName[]), sPropName);
}

public void CM_SpawnDoor(int iClient, char[] sSkin, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
{
	int iEntity = CreateEntityByName("prop_door_rotating");
	
	PrecacheModel("models/props_c17/door01_left.mdl");
	
	DispatchKeyValue(iEntity, "classname", "cel_door");
	DispatchKeyValue(iEntity, "model", "models/props_c17/door01_left.mdl");
	DispatchKeyValue(iEntity, "distance", "90");
	DispatchKeyValue(iEntity, "hardware", "1");
	DispatchKeyValue(iEntity, "returndelay", "5");
	DispatchKeyValue(iEntity, "skin", sSkin);
	DispatchKeyValue(iEntity, "spawnflags", "8192");
	DispatchKeyValue(iEntity, "speed", "100");
	
	DispatchSpawn(iEntity);
	
	fOrigin[2] += 54;
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	g_iOwner[iEntity] = iClient;
	
	CM_AddToCelCount(iClient);
	
	CM_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	CM_SetPropName(iEntity, "door");
	
	g_bCMEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
}

public void CM_SpawnInternet(int iClient, char[] sURL, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
{
	int iEntity = CreateEntityByName("prop_physics_override");
	
	PrecacheModel("models/props_lab/monitor02.mdl");
	
	DispatchKeyValue(iEntity, "classname", "cel_internet");
	DispatchKeyValue(iEntity, "model", "models/props_lab/monitor02.mdl");
	
	DispatchSpawn(iEntity);
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	DispatchKeyValue(iEntity, "skin", "1");
	
	CM_SetInternetURL(iEntity, sURL);
	
	g_iOwner[iEntity] = iClient;
	
	CM_AddToCelCount(iClient);
	
	CM_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	AcceptEntityInput(iEntity, "disablemotion");
	
	g_bCMEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bCanCopy[iEntity] = false;
}

public void CM_SpawnMusic(int iClient, char[] sAlias, char[] sSound, bool bLoop, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
{
	int iEntity = CreateEntityByName("prop_physics_override");
	
	PrecacheModel(g_sMusicModel);
	
	DispatchKeyValue(iEntity, "classname", "cel_music");
	DispatchKeyValue(iEntity, "model", g_sMusicModel);
	
	DispatchSpawn(iEntity);
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	Format(g_sMusic[iEntity], sizeof(g_sMusic[]), sSound);
	
	//Handle hTime = OpenSoundFile(sSound, true);
	
	//g_fMusicTime[iEntity] = GetSoundLengthFloat(hTime);
	
	//CloseHandle(hTime);
	
	g_iOwner[iEntity] = iClient;
	
	CM_AddToCelCount(iClient);
	
	CM_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	CM_SetPropName(iEntity, sAlias);
	
	AcceptEntityInput(iEntity, "disablemotion");
	
	g_bCMEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bCanCopy[iEntity] = false;
	
	g_bLoop[iEntity] = bLoop;
}

public void CM_SpawnProp(int iClient, char[] sAlias, char[] sModel, char[] sSpawnMode, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
{
	int iEntity = CreateEntityByName(sSpawnMode);
	
	PrecacheModel(sModel);
	
	DispatchKeyValue(iEntity, "classname", sSpawnMode);
	DispatchKeyValue(iEntity, "model", sModel);
	
	DispatchSpawn(iEntity);
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	g_iOwner[iEntity] = iClient;
	
	CM_AddToPropCount(iClient);
	
	CM_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	CM_SetPropName(iEntity, sAlias);
	
	g_bCMEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bCanCopy[iEntity] = true;
}

public void CM_SpawnSound(int iClient, char[] sAlias, char[] sSound, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
{
	int iEntity = CreateEntityByName("prop_physics_override");
	
	PrecacheModel(g_sSoundModel);
	
	DispatchKeyValue(iEntity, "classname", "cel_sound");
	DispatchKeyValue(iEntity, "model", g_sSoundModel);
	
	DispatchSpawn(iEntity);
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	Format(g_sSound[iEntity], sizeof(g_sSound[]), sSound);
	
	g_iOwner[iEntity] = iClient;
	
	CM_AddToCelCount(iClient);
	
	CM_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	CM_SetPropName(iEntity, sAlias);
	
	AcceptEntityInput(iEntity, "disablemotion");
	
	g_bCMEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bCanCopy[iEntity] = false;
}

public void CM_SubFromCelCount(int iClient)
{
	int iCount = CM_GetCelCount(iClient);
	
	iCount--;
	
	CM_SetCelCount(iClient, iCount);
}

public void CM_SubFromPropCount(int iClient)
{
	int iCount = CM_GetPropCount(iClient);
	
	iCount--;
	
	CM_SetPropCount(iClient, iCount);
}

public Action Timer_Copy(Handle hTimer)
{
	float fClientAngles[3], fClientOrigin[3], fFinalOrigin[3];
	
	for (int i = 1; i < GetMaxClients(); i++)
	{
		if (g_iCopyEnt[i] != -1 && g_bConnected[i])
		{
			GetClientAbsAngles(i, fClientAngles);
			GetClientAbsOrigin(i, fClientOrigin);
			
			fFinalOrigin[0] = fClientOrigin[0] + g_fCopyOrigin[i][0];
			fFinalOrigin[1] = fClientOrigin[1] + g_fCopyOrigin[i][1];
			fFinalOrigin[2] = fClientOrigin[2] + g_fCopyOrigin[i][2];
			
			TeleportEntity(g_iCopyEnt[i], fFinalOrigin, fClientAngles, NULL_VECTOR);
		}
	}
}

public Action Timer_DrawLand(Handle hTimer)
{
	float fLandPos[3];
	
	for (int i = 1; i < GetMaxClients(); i++)
	{
		if (g_bLandDrawing[i])
		{
			fLandPos = g_fLandOrigin[i][0];
			
			fLandPos[2] -= 100;
			
			CM_DrawLand(fLandPos, g_fLandOrigin[i][1], 0.1, g_iClientColor[i], false);
		}
	}
}

public Action Timer_Grab(Handle hTimer)
{
	float fClientAngles[3], fClientOrigin[3], fFinalOrigin[3];
	
	for (int i = 1; i < GetMaxClients(); i++)
	{
		if (g_iGrabEnt[i] != -1 && g_bConnected[i])
		{
			GetClientAbsAngles(i, fClientAngles);
			GetClientAbsOrigin(i, fClientOrigin);
			
			fFinalOrigin[0] = fClientOrigin[0] + g_fGrabOrigin[i][0];
			fFinalOrigin[1] = fClientOrigin[1] + g_fGrabOrigin[i][1];
			fFinalOrigin[2] = fClientOrigin[2] + g_fGrabOrigin[i][2];
			
			TeleportEntity(g_iGrabEnt[i], fFinalOrigin, fClientAngles, NULL_VECTOR);
		}
	}
}

public Action Timer_Hud(Handle hTimer)
{
	char sClassname[64], sMessage[256];
	
	for (int i = 1; i < GetMaxClients(); i++)
	{
		if (g_bConnected[i] && IsClientInGame(i))
		{
			int iLand = CM_IsCrosshairInsideLand(i);
			
			if (GetClientAimTarget(i, false) == -1)
			{
				Format(sMessage, sizeof(sMessage), "Balance: $%i", g_iBalance[i]);
			} else if (GetClientAimTarget(i, false)) {
				int iEntity = GetClientAimTarget(i, false);
				
				GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
				
				if (StrEqual(sClassname, "player"))
				{
					Format(sMessage, sizeof(sMessage), "Name: %N\nProps Spawned: %i\nBalance: $%i", iEntity, CM_GetPropCount(iEntity), g_iBalance[i]);
				}
				
				if (g_bCMEntity[iEntity])
				{
					GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
					
					if (StrEqual(sClassname, "cel_door"))
					{
						if (CM_CheckOwner(i, iEntity))
						{
							Format(sMessage, sizeof(sMessage), "Cel: Door");
						} else {
							Format(sMessage, sizeof(sMessage), "Owner: %N\nCel: Door", g_iOwner[iEntity]);
						}
					} else if (StrEqual(sClassname, "cel_internet"))
					{
						if (CM_CheckOwner(i, iEntity))
						{
							Format(sMessage, sizeof(sMessage), "URL: %s", g_sInternetURL[iEntity]);
						} else {
							Format(sMessage, sizeof(sMessage), "Owner: %N\nURL: %s", g_iOwner[iEntity], g_sInternetURL[iEntity]);
						}
					} else if (StrEqual(sClassname, "cel_music"))
					{
						if (CM_CheckOwner(i, iEntity))
						{
							Format(sMessage, sizeof(sMessage), "Song: %s", g_sPropName[iEntity]);
						} else {
							Format(sMessage, sizeof(sMessage), "Owner: %N\nSong: %s", g_iOwner[iEntity], g_sPropName[iEntity]);
						}
					} else if (StrEqual(sClassname, "cel_sound"))
					{
						if (CM_CheckOwner(i, iEntity))
						{
							Format(sMessage, sizeof(sMessage), "Sound: %s", g_sPropName[iEntity]);
						} else {
							Format(sMessage, sizeof(sMessage), "Owner: %N\nSound: %s", g_iOwner[iEntity], g_sPropName[iEntity]);
						}
					} else if (CM_CheckOwner(i, iEntity))
					{
						Format(sMessage, sizeof(sMessage), "Propname: %s", g_sPropName[iEntity]);
					} else {
						Format(sMessage, sizeof(sMessage), "Owner: %N\nPropname: %s", g_iOwner[iEntity], g_sPropName[iEntity]);
					}
				} else {
					Format(sMessage, sizeof(sMessage), "Balance: $%i", g_iBalance[i]);
				}
			} else if (iLand != -1) {
				Format(sMessage, sizeof(sMessage), "Land: %N", iLand);
			}
			CM_SendHudMessage(i, 2, 3.025, -0.110, g_iClientColor[i][0], g_iClientColor[i][1], g_iClientColor[i][2], g_iClientColor[i][3], 0, 0.6, 0.01, 0.01, 0.01, sMessage);
		}
	}
}

public Action Timer_InLand(Handle hTimer)
{
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientConnected(i) && g_bConnected[i])
		{
			int iLand = CM_IsClientInsideLand(i);
			
			if (iLand != -1)
			{
				if (!g_bSentMessage[i])
				{
					g_bIsInLand[i] = true;
				}
				
				SetEntityGravity(i, g_fLandGravity[iLand]);
			} else {
				g_bIsInLand[i] = false;
				g_bSentMessage[i] = false;
				
				SetEntityGravity(i, 1.0);
			}
			
			if (g_bIsInLand[i])
			{
				CPrintToChat(i, "{blue}|CelMod|{default} You have entered {green}%N{default}'s land.", iLand);
				
				g_bSentMessage[i] = true;
				
				g_bIsInLand[i] = false;
			}
		}
	}
}

public Action Timer_AddMoney(Handle hTimer)
{
	for (int i = 1; i < MaxClients; i++)
	{
		if (g_bConnected[i])
		{
			g_iBalance[i] += 2;
			
			CM_SaveClientBalance(i);
		}
	}
}

public Action Timer_Remove(Handle hTimer, any iEntity)
{
	if (IsValidEntity(iEntity))
	{
		g_bCanCopy[iEntity] = false;
		
		g_bCMEntity[iEntity] = false;
		
		StopSound(iEntity, 2, g_sSound[iEntity]);
		StopSound(iEntity, 3, g_sMusic[iEntity]);
		
		g_bLoop[iEntity] = false;
		g_bPlaying[iEntity] = false;
		
		AcceptEntityInput(iEntity, "kill");
	}
}

public Action Timer_Positions(Handle hTimer)
{
	float fOrigin[3];
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (g_bConnected[i])
		{
			if (g_bGettingPositions[i])
			{
				CM_GetEndPoint(i, fOrigin);
				
				g_fLandOrigin[i][1] = fOrigin;
			}
		}
	}
}

public Action Timer_RepeatMusic(Handle hTimer, any iEntity)
{
	if (g_bLoop[iEntity] && g_bPlaying[iEntity])
	{
		StopSound(iEntity, 0, g_sMusic[iEntity]);
		
		PrecacheSound(g_sMusic[iEntity]);
		EmitSoundToAll(g_sMusic[iEntity], iEntity, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}
}

//Menus:
public int Menu_Gravity(Menu mMenu, MenuAction maAction, int iParam1, int iParam2)
{
	switch (maAction)
	{
		case MenuAction_Display:
		{
			Panel pPanel = view_as<Panel>(iParam2);
			
			pPanel.SetTitle("Land Gravity");
		}
		
		case MenuAction_Select:
		{
			char sInfo[32];
			
			mMenu.GetItem(iParam2, sInfo, sizeof(sInfo));
			
			if (StrEqual(sInfo, "Low"))
			{
				g_fLandGravity[iParam1] = 0.5;
				
				CPrintToChat(iParam1, "{blue}|CelMod|{default} Set Land Gravity to {green}low{default}.");
			} else if (StrEqual(sInfo, "Normal"))
			{
				g_fLandGravity[iParam1] = 1.0;
				
				CPrintToChat(iParam1, "{blue}|CelMod|{default} Set Land Gravity to {green}normal{default}.");
			} else if (StrEqual(sInfo, "High"))
			{
				g_fLandGravity[iParam1] = 2.0;
				
				CPrintToChat(iParam1, "{blue}|CelMod|{default} Set Land Gravity to {green}high{default}.");
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

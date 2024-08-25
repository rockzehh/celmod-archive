#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "DarkNoodlez"
#define PLUGIN_VERSION "1.00.0"

#include <sourcemod>
#include <morecolors>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <buttondetector>
#include <s-a-s>

#pragma newdecls required

#define MAXENTITIES 2048
#define MAX_BUFFER_LENGTH 512

bool g_bCelEntity[MAXENTITIES + 1] = false;
bool g_bCanCopy[MAXENTITIES + 1] = false;
bool g_bConnected[MAXPLAYERS + 1] = false;
bool g_bCopyQueue[MAXPLAYERS + 1] = false;
bool g_bFadeColor[MAXENTITIES + 1] = false;
bool g_bGettingPositions[MAXPLAYERS + 1] = false;
bool g_bGodMode[MAXPLAYERS + 1] = false;
bool g_bIsInLand[MAXPLAYERS + 1] = false;
bool g_bLandDrawing[MAXPLAYERS + 1] = false;
bool g_bMotion[MAXENTITIES + 1] = false;
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

ConVar g_cvCelLimit;
ConVar g_cvPropLimit;

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
int g_iSliderEnt[MAXENTITIES + 1];

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
	description = "", 
	version = PLUGIN_VERSION, 
	url = ""
};

public void OnPluginStart()
{
	BuildPath(Path_SM, g_sColorDB, PLATFORM_MAX_PATH, "data/celmod/colors.txt");
	if (!FileExists(g_sColorDB))
		SetFailState("|CM|: '%s' not found!", g_sColorDB);
	
	BuildPath(Path_SM, g_sSpawnDB, PLATFORM_MAX_PATH, "data/celmod/spawns.txt");
	if (!FileExists(g_sSpawnDB))
		SetFailState("|CM|: '%s' not found!", g_sSpawnDB);
	
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
	
	RegConsoleCmd("+copy", Command_StartCopy, "Starts copying the prop you are looking at.");
	RegConsoleCmd("+grab", Command_StartGrab, "Starts grabing the prop you are looking at.");
	RegConsoleCmd("-copy", Command_StopCopy, "Stops copying the prop.");
	RegConsoleCmd("-grab", Command_StopGrab, "Stops grabbing the prop.");
	RegConsoleCmd("noclip", Command_NoClip, "Enables/disables noclip.");
	RegConsoleCmd("sm_amt", Command_AMT, "Changes the alpha of the entity you are looking at.");
	RegConsoleCmd("sm_color", Command_Color, "Colors the entity you are looking at.");
	RegConsoleCmd("sm_del", Command_Delete, "Removes the entity you are looking at.");
	RegConsoleCmd("sm_delall", Command_DeleteAll, "Removes all your entities.");
	RegConsoleCmd("sm_delete", Command_Delete, "Removes the entity you are looking at.");
	RegConsoleCmd("sm_deleteall", Command_DeleteAll, "Removes all your entities.");
	RegConsoleCmd("sm_door", Command_Door, "Spawns a door.");
	RegConsoleCmd("sm_fly", Command_Fly, "Enables noclip on the client.");
	RegConsoleCmd("sm_freeze", Command_Freeze, "Disables motion on the entity you are looking at.");
	RegConsoleCmd("sm_internet", Command_Internet, "Spawns a internet cel.");
	RegConsoleCmd("sm_kill", Command_Kill, "Forces the client to suicide.");
	RegConsoleCmd("sm_land", Command_Land, "Creates a building zone.");
	RegConsoleCmd("sm_landgravity", Command_LandGravity, "Changes the land gravity.");
	RegConsoleCmd("sm_msg", Command_Message, "Sends a private message to a player.");
	RegConsoleCmd("sm_reply", Command_Reply, "Replies to the previous message.");
	RegConsoleCmd("sm_rotate", Command_Rotate, "Rotates the entity you are looking at.");
	RegConsoleCmd("sm_save", Command_SaveBuild, "Saves your props into a build.");
	RegConsoleCmd("sm_seturl", Command_SetURL, "Sets the url of the internet cel you are looking at.");
	RegConsoleCmd("sm_skin", Command_Skin, "Changes the skin of the entity you are looking at.");
	//RegConsoleCmd("sm_slider", Command_Slider, "Creates a slider on the entity you are looking at.");
	RegConsoleCmd("sm_smove", Command_SMove, "Adds points to the origin of the entity that you are looking at.");
	RegConsoleCmd("sm_solid", Command_Solid, "Enables/disables solidicity on the entity you are looking at.");
	RegConsoleCmd("sm_spawn", Command_Spawn, "Spawns a prop by alias");
	RegConsoleCmd("sm_straight", Command_Straight, "Straightens the prop you are looking at.");
	RegConsoleCmd("sm_unfreeze", Command_UnFreeze, "Enables motion on the entity you are looking at.");
	
	if (ConCommand_HasFlags("noclip", FCVAR_CHEAT))
		ConCommand_RemoveFlags("noclip", FCVAR_CHEAT);
	
	g_cvCelLimit = CreateConVar("cm_cel_limit", "25", "Limit's the number of cels that can be spawned.");
	g_cvPropLimit = CreateConVar("cm_prop_limit", "175", "Limit's the number of props that can be spawn.");
	
	HookConVarChange(g_cvCelLimit, Cel_ConVarChanged);
	HookConVarChange(g_cvPropLimit, Cel_ConVarChanged);
	
	Cel_SetCelLimit(GetConVarInt(g_cvCelLimit));
	Cel_SetPropLimit(GetConVarInt(g_cvPropLimit));
}

public void OnMapStart()
{
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
	
	//g_hHudTimer = CreateTimer(0.1, Timer_Hud, _, TIMER_REPEAT);
	
	g_hInLand = CreateTimer(0.1, Timer_InLand, _, TIMER_REPEAT);
	g_hLandDrawing = CreateTimer(0.1, Timer_DrawLand, _, TIMER_REPEAT);
	
	//g_hMoney = CreateTimer(240.0, Timer_AddMoney, _, TIMER_REPEAT);
	
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
	
	Cel_SetAuthID(iClient);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/saves/%s", g_sAuthID[iClient]);
	if (!DirExists(sPath))
	{
		CreateDirectory(sPath, 511);
	}
	
	Cel_SetCelCount(iClient, 0);
	Cel_SetPropCount(iClient, 0);
	
	g_iCopyEnt[iClient] = -1;
	g_iGrabEnt[iClient] = -1;
	
	g_iBalance[iClient] = 0;
	
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
}

public void OnClientDisconnect(int iClient)
{
	g_iCopyEnt[iClient] = -1;
	g_iGrabEnt[iClient] = -1;
	
	g_iLastPlayer[iClient] = -1;
	
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
		if (Cel_CheckOwner(iClient, i))
		{
			CreateTimer(0.10, Timer_Remove, i);
		}
	}
}

public void OnButtonPressed(int iClient, int iButton)
{
	char sClassname[64];
	
	float fClientOrigin[3], fEntityOrigin[3];
	
	if (iButton == 32)
	{
		if (!g_bButtonUse[iClient])
		{
			g_bButtonUse[iClient] = true;
			
			if (GetClientAimTarget(iClient, false) != -1)
			{
				int iEntity = GetClientAimTarget(iClient, false);
				
				if (g_bCelEntity[iEntity])
				{
					GetClientAbsOrigin(iClient, fClientOrigin);
					Cel_GetEntityOrigin(iEntity, fEntityOrigin);
					
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
					
					if (StrEqual(sClassname, "cel_slider"))
					{
						if (g_fEntityTime[iClient] < GetGameTime() - 1)
						{
							if (fDistance <= 50)
							{
								AcceptEntityInput(g_iSliderEnt[iEntity], "Toggle");
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
										//g_hMusicLoop[iEntity] = CreateTimer(g_fMusicTime[iEntity], Timer_RepeatMusic, iEntity, TIMER_REPEAT);
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
	if (g_bButtonUse[iClient])
	{
		g_bButtonUse[iClient] = false;
	}
}

//Commands:
public Action Command_AMT(int iClient, int iArgs)
{
	char sAlpha[64];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]amt{default} <alpha>");
		return Plugin_Handled;
	}
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlpha, sizeof(sAlpha));
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		int iAlpha = StringToInt(sAlpha);
		
		Cel_SetEntityColor(iEntity, g_iColor[iEntity][0], g_iColor[iEntity][1], g_iColor[iEntity][2], iAlpha);
		
		Cel_ChangeBeam(iClient, iEntity);
		
		Cel_ReplyToCommand(iClient, "Alpha transparency has been changed to {green}%i{default}.", iAlpha);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Color(int iClient, int iArgs)
{
	char sColor[64], sColorString[96], sColorBuffer[3][32];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]color{default} <color>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor, sizeof(sColor));
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		KeyValues kvColors = new KeyValues("Colors");
		
		kvColors.ImportFromFile(g_sColorDB);
		
		kvColors.GetString(sColor, sColorString, sizeof(sColorString), "null");
		
		if (StrEqual(sColorString, "null"))
		{
			Cel_ReplyToCommand(iClient, "Color not found in database.");
			return Plugin_Handled;
		}
		
		kvColors.Close();
		
		ExplodeString(sColorString, "^", sColorBuffer, 3, sizeof(sColorBuffer[]));
		
		Cel_SetEntityColor(iEntity, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), g_iColor[iEntity][3]);
		
		g_bFadeColor[iEntity] = false;
		
		Cel_ChangeBeam(iClient, iEntity);
		
		Cel_ReplyToCommand(iClient, "Set entity color to {green}%s{default}.", sColor);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Delete(int iClient, int iArgs)
{
	char sClassname[64];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iTarget = GetClientAimTarget(iClient, false);
	
	int iEntity = EntRefToEntIndex(iTarget);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
		
		g_bCanCopy[iEntity] = false;
		
		if (StrContains(sClassname, "prop_") != -1)
		{
			Cel_ReplyToCommand(iClient, "Removed physics entity.");
			
			Cel_SubFromPropCount(iClient);
		} else if (StrContains(sClassname, "cel_") != -1)
		{
			Cel_ReplyToCommand(iClient, "Removed cel entity.");
			
			Cel_SubFromCelCount(iClient);
		} else if (StrEqual(sClassname, "cel_music"))
		{
			Cel_ReplyToCommand(iClient, "Removed music cel.");
			
			StopSound(iEntity, 3, g_sMusic[iEntity]);
			
			g_bLoop[iEntity] = false;
			g_bPlaying[iEntity] = false;
			
			Cel_SubFromCelCount(iClient);
		} else if (StrEqual(sClassname, "cel_sound"))
		{
			Cel_ReplyToCommand(iClient, "Removed sound cel.");
			
			Cel_SubFromCelCount(iClient);
		}
		
		Cel_DissolveEntity(iEntity);
		
		Cel_RemovalBeam(iClient, iEntity);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_DeleteAll(int iClient, int iArgs)
{
	int iFinal = Cel_GetCelCount(iClient) + Cel_GetPropCount(iClient);
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (Cel_CheckOwner(iClient, i))
		{
			CreateTimer(0.10, Timer_Remove, i);
		}
	}
	
	Cel_SetCelCount(iClient, 0);
	Cel_SetPropCount(iClient, 0);
	
	Cel_ReplyToCommand(iClient, "Removed {green}%i{default} entities.", iFinal);
	
	return Plugin_Handled;
}

public Action Command_Door(int iClient, int iArgs)
{
	if (Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "You have reached the max cel limit.");
		return Plugin_Handled;
	}
	
	char sSkin[64];
	float fOrigin[3], fAngles[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]door{default} <skin>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sSkin, sizeof(sSkin));
	
	Cel_GetEndPoint(iClient, fOrigin);
	GetClientAbsAngles(iClient, fAngles);
	
	Cel_SpawnDoor(iClient, sSkin, fOrigin, fAngles, 255, 255, 255, 255);
	
	return Plugin_Handled;
}

public Action Command_Fly(int iClient, int iArgs)
{
	MoveType iMoveType = GetEntityMoveType(iClient);
	
	if (iMoveType == MOVETYPE_NOCLIP)
	{
		SetEntityMoveType(iClient, MOVETYPE_WALK);
		
		Cel_ReplyToCommand(iClient, "Fly has been disabled.");
	} else {
		SetEntityMoveType(iClient, MOVETYPE_NOCLIP);
		
		Cel_ReplyToCommand(iClient, "Fly has been enabled.");
	}
	
	return Plugin_Handled;
}

public Action Command_Freeze(int iClient, int iArgs)
{
	char sClassname[64];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
		
		if (StrContains(sClassname, "prop_door_rotating") != -1)
		{
			Cel_ReplyToCommand(iClient, "Door has been locked.");
			
			AcceptEntityInput(iEntity, "lock");
		} else {
			Cel_ReplyToCommand(iClient, "Disabled motion on %s.", StrContains(sClassname, "prop_") != -1 ? "prop" : "cel");
			
			g_bMotion[iEntity] = false;
			
			AcceptEntityInput(iEntity, "disablemotion");
		}
		
		Cel_ChangeBeam(iClient, iEntity);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Internet(int iClient, int iArgs)
{
	if (Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "You have reached the cel prop limit.");
		return Plugin_Handled;
	}
	
	float fAngles[3], fCOrigin[3], fOrigin[3];
	
	GetClientAbsOrigin(iClient, fCOrigin);
	GetClientEyeAngles(iClient, fAngles);
	
	fOrigin[0] = FloatAdd(fCOrigin[0], Cosine(DegToRad(fAngles[1])) * 50);
	fOrigin[1] = FloatAdd(fCOrigin[1], Sine(DegToRad(fAngles[1])) * 50);
	fOrigin[2] = fCOrigin[2] + 32;
	
	Cel_SpawnInternet(iClient, "http://steamcommunity.com/groups/cel-community", fOrigin, g_fZero, 255, 255, 255, 255);
	
	return Plugin_Handled;
}

public Action Command_Kill(int iClient, int iArgs)
{
	ForcePlayerSuicide(iClient);
	
	Cel_ReplyToCommand(iClient, "You have killed yourself.");
	
	return Plugin_Handled;
}

public Action Command_Land(int iClient, int iArgs)
{
	bool bDidHitTop = false;
	float fOrigin[3];
	
	if (g_bStartedLand[iClient])
	{
		if (Cel_IsCrosshairInsideLand(iClient) != -1)
		{
			if (Cel_IsCrosshairInsideLand(iClient) == iClient)
			{  } else {
				Cel_ReplyToCommand(iClient, "You cannot finish your land inside another land.");
				return Plugin_Handled;
			}
		} else {
			Cel_GetEndPoint(iClient, fOrigin);
			
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
			
			Cel_ReplyToCommand(iClient, "Land completed.");
			
			return Plugin_Handled;
		}
	} else {
		if (Cel_IsCrosshairInsideLand(iClient) != -1)
		{
			if (Cel_IsCrosshairInsideLand(iClient) == iClient)
			{  } else {
				Cel_ReplyToCommand(iClient, "You cannot start your land inside another land.");
				return Plugin_Handled;
			}
		} else {
			g_bStartedLand[iClient] = true;
			g_bLandDrawing[iClient] = true;
			g_bGettingPositions[iClient] = true;
			
			Cel_GetEndPoint(iClient, fOrigin);
			
			g_fLandOrigin[iClient][0] = fOrigin;
			
			Cel_ReplyToCommand(iClient, "Type {green}[tag]land{default} again to complete the land.");
			
			return Plugin_Handled;
		}
	}
	
	return Plugin_Handled;
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

public Action Command_Message(int iClient, int iArgs)
{
	char sArg[128], sMessage[512];
	
	if (iArgs < 2)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]msg{default} <recipent> <message>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sArg, sizeof(sArg));
	GetCmdArgString(sMessage, sizeof(sMessage));
	
	int iTarget = FindTarget(iClient, sArg, true, false);
	
	if (iTarget == -1)
	{
		Cel_ReplyToCommand(iClient, "{green}%N{default} is not a valid client!", iTarget);
		return Plugin_Handled;
	}
	
	if (iTarget == iClient)
	{
		Cel_ReplyToCommand(iClient, "You cannot message yourself!");
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

public Action Command_NoClip(int iClient, int iArgs)
{
	MoveType iMoveType = GetEntityMoveType(iClient);
	
	if (iMoveType == MOVETYPE_NOCLIP)
	{
		SetEntityMoveType(iClient, MOVETYPE_WALK);
		
		PrintToConsole(iClient, "noclip OFF");
	} else {
		SetEntityMoveType(iClient, MOVETYPE_NOCLIP);
		
		PrintToConsole(iClient, "noclip ON");
	}
	
	return Plugin_Handled;
}

public Action Command_Reply(int iClient, int iArgs)
{
	char sMessage[512];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]reply{default} <message>");
		return Plugin_Handled;
	}
	
	GetCmdArgString(sMessage, sizeof(sMessage));
	
	if (g_iLastPlayer[iClient] == -1)
	{
		Cel_ReplyToCommand(iClient, "No-one has messaged you yet! Type {green}[tag]msg{default} to message someone!");
		return Plugin_Handled;
	}
	
	CPrintToChat(iClient, "{blue}|CM|{default} To: {green}%N{default} - %s", g_iLastPlayer[iClient], sMessage);
	CPrintToChat(g_iLastPlayer[iClient], "{blue}|CM|{default} From: {green}%N{default} - %s", iClient, sMessage);
	
	ClientCommand(g_iLastPlayer[iClient], "play friends/message.wav");
	
	return Plugin_Handled;
}

public Action Command_Rotate(int iClient, int iArgs)
{
	char sX[64], sY[64], sZ[64];
	float fAngles[3];
	
	if (iArgs < 3)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]rotate{default} <x> <y> <z>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(3, sZ, sizeof(sZ));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		Cel_GetEntityAngles(iEntity, fAngles);
		
		fAngles[0] += StringToFloat(sX);
		fAngles[1] += StringToFloat(sY);
		fAngles[2] += StringToFloat(sZ);
		
		TeleportEntity(iEntity, NULL_VECTOR, fAngles, NULL_VECTOR);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_SaveBuild(int iClient, int iArgs)
{
	char sBuildName[256];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]save{default} <buildname>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sBuildName, sizeof(sBuildName));
	
	Cel_SaveBuild(iClient, sBuildName);
	
	return Plugin_Handled;
}

public Action Command_Say(int iClient, const char[] sCommand, int iArgs)
{
	char sMessage[512], sName[32], sNickname[64];
	
	if (IsChatTrigger())
	{
		return Plugin_Handled;
	} else {
		GetCmdArgString(sMessage, sizeof(sMessage));
		
		StripQuotes(sMessage);
		
		CRemoveTags(sMessage, sizeof(sMessage));
		
		GetClientName(iClient, sName, sizeof(sName));
		
		SAS_GetNickname(iClient, sNickname, sizeof(sNickname));
		
		if (StrEqual(sNickname, "celmod"))
		{
			Cel_PrintToChatAll("%s", sMessage);
		} else {
			CPrintToChatAll("%s: %s", StrEqual(sNickname, "null") ? sName : sNickname, sMessage);
		}
		
		return Plugin_Handled;
	}
}

public Action Command_SetURL(int iClient, int iArgs)
{
	char sURL[256];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]seturl{default} <url>");
		return Plugin_Handled;
	}
	
	GetCmdArgString(sURL, sizeof(sURL));
	
	if (StrContains(sURL, "http://", false) != -1 || StrContains(sURL, "https://", false) != -1)
	{  } else {
		Format(sURL, sizeof(sURL), "http://%s", sURL);
	}
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		Cel_SetInternetURL(iEntity, sURL);
		
		Cel_ChangeBeam(iClient, iEntity);
		
		Cel_ReplyToCommand(iClient, "Set internet url to {green}%s{default}.", sURL);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Skin(int iClient, int iArgs)
{
	char sSkin[64];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]skin{default} <skin>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sSkin, sizeof(sSkin));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		DispatchKeyValue(iEntity, "skin", sSkin);
		
		Cel_ChangeBeam(iClient, iEntity);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Slider(int iClient, int iArgs)
{
	char sMoveDirection[64], sOriginString[64], sSpeed[64], sTargetname[128], sX[64], sY[64], sZ[64];
	float fAngles[3], fMax[3], fMin[3], fOrigin[3];
	
	if (iArgs < 4)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]slider{default} <x> <y> <z> <speed>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(3, sZ, sizeof(sZ));
	GetCmdArg(4, sSpeed, sizeof(sSpeed));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		Cel_GetEntityAngles(iEntity, fAngles);
		Cel_GetEntityOrigin(iEntity, fOrigin);
		
		Entity_GetMaxSize(iEntity, fMax);
		Entity_GetMinSize(iEntity, fMin);
		
		DispatchKeyValue(iEntity, "classname", "cel_slider");
		DispatchKeyValue(iEntity, "targetname", sTargetname);
		
		int iDoor = CreateEntityByName("func_door");
		
		Format(sMoveDirection, sizeof(sMoveDirection), "%s %s %s", sX, sY, sZ);
		Format(sOriginString, sizeof(sOriginString), "%f %f %f", fOrigin[0], fOrigin[1], fOrigin[2]);
		Format(sTargetname, sizeof(sTargetname), "slider%i%i", iClient, GetRandomInt(0, 2048));
		
		DispatchKeyValue(iDoor, "classname", "cel_slider");
		DispatchKeyValue(iDoor, "disablereceiveshadows", "0");
		DispatchKeyValue(iDoor, "disableshadows", "0");
		DispatchKeyValue(iDoor, "dmg", "0");
		DispatchKeyValue(iDoor, "forceclosed", "0");
		DispatchKeyValue(iDoor, "health", "0");
		DispatchKeyValue(iDoor, "ignoredebris", "0");
		DispatchKeyValue(iDoor, "lip", "0");
		DispatchKeyValue(iDoor, "locked_sentence", "0");
		DispatchKeyValue(iDoor, "loopmovesound", "0");
		DispatchKeyValue(iDoor, "movedir", sMoveDirection);
		DispatchKeyValue(iDoor, "origin", sOriginString);
		DispatchKeyValue(iDoor, "renderamt", "0");
		DispatchKeyValue(iDoor, "rendercolor", "0 0 0");
		DispatchKeyValue(iDoor, "renderfx", "0");
		DispatchKeyValue(iDoor, "rendermode", "10");
		DispatchKeyValue(iDoor, "spawnflags", "288");
		DispatchKeyValue(iDoor, "spawnpos", "0");
		DispatchKeyValue(iDoor, "speed", sSpeed);
		DispatchKeyValue(iDoor, "targetname", "slider");
		DispatchKeyValue(iDoor, "unlocked_sentence", "0");
		DispatchKeyValue(iDoor, "wait", "4");
		
		Cel_SubFromPropCount(iClient);
		
		Cel_AddToCelCount(iClient);
		
		DispatchSpawn(iDoor);
		
		TeleportEntity(iDoor, fOrigin, fAngles, NULL_VECTOR);
		
		Entity_SetMaxSize(iDoor, fMax);
		Entity_SetMinSize(iDoor, fMin);
		
		SetVariantString(sTargetname);
		AcceptEntityInput(iDoor, "SetParent");
		
		g_iSliderEnt[iEntity] = iDoor;
		
		Cel_ReplyToCommand(iClient, "Created slider cel.");
	} else {
		Cel_NotYours(iClient);
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
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]smove{default} <x> <y> <z>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(3, sZ, sizeof(sZ));
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		Cel_GetEntityOrigin(iEntity, fOrigin);
		
		fOrigin[0] += StringToFloat(sX);
		fOrigin[1] += StringToFloat(sY);
		fOrigin[2] += StringToFloat(sZ);
		
		TeleportEntity(iEntity, fOrigin, NULL_VECTOR, NULL_VECTOR);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Solid(int iClient, int iArgs)
{
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		if (g_bSolid[iEntity])
		{
			DispatchKeyValue(iEntity, "solid", "4");
			
			Cel_ReplyToCommand(iClient, "Turned solidicity off.");
			
			g_bSolid[iEntity] = false;
		} else {
			DispatchKeyValue(iEntity, "solid", "6");
			
			Cel_ReplyToCommand(iClient, "Turned solidicity on.");
			
			g_bSolid[iEntity] = true;
		}
		
		Cel_ChangeBeam(iClient, iEntity);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Spawn(int iClient, int iArgs)
{
	if (Cel_CheckPropCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "You have reached the max prop limit.");
		return Plugin_Handled;
	}
	
	char sAlias[64], sModel[128], sSpawnMode[128], sSpawnOptions[2][128], sSpawnString[256];
	float fOrigin[3], fAngles[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]spawn{default} <alias>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	
	KeyValues kvSpawn = new KeyValues("Props");
	
	kvSpawn.ImportFromFile(g_sSpawnDB);
	
	kvSpawn.JumpToKey("Models", false);
	
	kvSpawn.GetString(sAlias, sSpawnString, sizeof(sSpawnString), "null");
	
	if (StrEqual(sSpawnString, "null", true))
	{
		Cel_ReplyToCommand(iClient, "{green}%s{default} does not exist in the spawn database!", sAlias);
		return Plugin_Handled;
	}
	
	ExplodeString(sSpawnString, "^", sSpawnOptions, 2, sizeof(sSpawnOptions[]));
	
	strcopy(sModel, sizeof(sModel), sSpawnOptions[1]);
	strcopy(sSpawnMode, sizeof(sSpawnMode), sSpawnOptions[0]);
	
	//Old SpawnDB Compatible
	/*if (kvSpawn.JumpToKey(sAlias, false))
	{
		kvSpawn.GetString("model", sModel, sizeof(sModel), "null");
		kvSpawn.GetString("spawnmode", sSpawnMode, sizeof(sSpawnMode), "null");
	} else {
		Cel_ReplyToCommand(iClient, "{green}%s{default} does not exist in the spawn database!", sAlias);
		return Plugin_Handled;
	}*/
	
	kvSpawn.Close();
	
	Cel_GetEndPoint(iClient, fOrigin);
	GetClientAbsAngles(iClient, fAngles);
	
	Cel_SpawnProp(iClient, sAlias, sModel, sSpawnMode, fOrigin, fAngles, 255, 255, 255, 255);
	
	return Plugin_Handled;
}

public Action Command_StartCopy(int iClient, int iArgs)
{
	char sModel[128], sPropname[64], sSkin[64];
	float fAngles[3], fClientAngles[3], fClientOrigin[3], fOrigin[3];
	int iColor[4], iSolid;
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (Cel_CheckPropCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "You have reached the max prop limit.");
		return Plugin_Handled;
	}
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (!g_bCanCopy[iEntity])
	{
		Cel_ReplyToCommand(iClient, "You cannot copy this entity!");
		return Plugin_Handled;
	}
	
	if (g_iCopyEnt[iClient] != -1)
	{
		Cel_ReplyToCommand(iClient, "You are already copying something!");
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		IntToString(GetEntProp(iEntity, Prop_Data, "m_nSkin", 1), sSkin, sizeof(sSkin));
		iSolid = GetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 4, 0);
		
		GetEntityRenderColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
		
		Cel_GetPropName(iEntity, sPropname);
		
		Cel_GetEntityAngles(iEntity, fAngles);
		Cel_GetEntityOrigin(iEntity, fOrigin);
		
		GetClientAbsAngles(iClient, fClientAngles);
		GetClientAbsOrigin(iClient, fClientOrigin);
		
		int iCopyEnt = CreateEntityByName("prop_physics_override");
		
		PrecacheModel(sModel);
		
		DispatchKeyValue(iCopyEnt, "model", sModel);
		DispatchKeyValue(iCopyEnt, "skin", sSkin);
		
		DispatchSpawn(iCopyEnt);
		
		Cel_SetEntityColor(iCopyEnt, iColor[0], iColor[1], iColor[2], iColor[3]);
		
		SetEntityRenderColor(iCopyEnt, 0, 0, 255, 128);
		SetEntityRenderFx(iCopyEnt, RENDERFX_DISTORT);
		
		TeleportEntity(iCopyEnt, fOrigin, fAngles, NULL_VECTOR);
		
		g_fCopyOrigin[iClient][0] = fOrigin[0] - fClientOrigin[0];
		g_fCopyOrigin[iClient][1] = fOrigin[1] - fClientOrigin[1];
		g_fCopyOrigin[iClient][2] = fOrigin[2] - fClientOrigin[2];
		
		Cel_SetPropName(iCopyEnt, sPropname);
		
		SetEntProp(iCopyEnt, Prop_Send, "m_CollisionGroup", iSolid);
		
		AcceptEntityInput(iCopyEnt, "disablemotion");
		
		g_iOwner[iCopyEnt] = iClient;
		
		Cel_AddToPropCount(iClient);
		
		g_bCelEntity[iCopyEnt] = true;
		
		g_bCanCopy[iCopyEnt] = true;
		
		g_iCopyEnt[iClient] = iCopyEnt;
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StartGrab(int iClient, int iArgs)
{
	float fOrigin[3], fEntityOrigin[3];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (g_iGrabEnt[iClient] != -1)
	{
		Cel_ReplyToCommand(iClient, "You are already grabbing something!");
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		GetClientAbsOrigin(iClient, fOrigin);
		Cel_GetEntityOrigin(iEntity, fEntityOrigin);
		
		g_fGrabOrigin[iClient][0] = fEntityOrigin[0] - fOrigin[0];
		g_fGrabOrigin[iClient][1] = fEntityOrigin[1] - fOrigin[1];
		g_fGrabOrigin[iClient][2] = fEntityOrigin[2] - fOrigin[2];
		
		SetEntityRenderColor(iEntity, 0, 255, 0, 128);
		SetEntityRenderFx(iEntity, RENDERFX_DISTORT);
		
		g_iGrabEnt[iClient] = iEntity;
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StopCopy(int iClient, int iArgs)
{
	if (g_iCopyEnt[iClient] == -1)
	{
		Cel_ReplyToCommand(iClient, "You aren't copying something!");
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
		Cel_ReplyToCommand(iClient, "You aren't grabbing something!");
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

public Action Command_Straight(int iClient, int iArgs)
{
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		TeleportEntity(iEntity, NULL_VECTOR, g_fZero, NULL_VECTOR);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_UnFreeze(int iClient, int iArgs)
{
	char sClassname[64];
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	if (!g_bCelEntity[iEntity])
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if (Cel_CheckOwner(iClient, iEntity))
	{
		GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
		
		if (StrContains(sClassname, "prop_door_rotating") != -1)
		{
			Cel_ReplyToCommand(iClient, "Door has been unlocked.");
			
			AcceptEntityInput(iEntity, "unlock");
		} else {
			Cel_ReplyToCommand(iClient, "Enabled motion on %s.", StrContains(sClassname, "prop_") != -1 ? "prop" : "cel");
			
			g_bMotion[iEntity] = true;
			
			AcceptEntityInput(iEntity, "enablemotion");
		}
		
		Cel_ChangeBeam(iClient, iEntity);
	} else {
		Cel_NotYours(iClient);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

//Stocks:
public void Cel_AddToCelCount(int iClient)
{
	int iCount = Cel_GetCelCount(iClient);
	
	iCount++; Cel_SetCelCount(iClient, iCount);
}

public void Cel_AddToPropCount(int iClient)
{
	int iCount = Cel_GetPropCount(iClient);
	
	iCount++; Cel_SetPropCount(iClient, iCount);
}

public void Cel_ChangeBeam(int iClient, int iEntity)
{
	char sSound[96];
	
	float fClientOrigin[3], fEntityOrigin[3];
	
	GetClientAbsOrigin(iClient, fClientOrigin);
	
	Cel_GetEntityOrigin(iEntity, fEntityOrigin);
	
	TE_SetupBeamPoints(fClientOrigin, fEntityOrigin, g_iPhys, g_iHalo, 0, 15, 0.25, 5.0, 5.0, 1, 0.0, g_iWhite, 10); TE_SendToAll();
	TE_SetupSparks(fEntityOrigin, NULL_VECTOR, 2, 5); TE_SendToAll();
	
	Format(sSound, sizeof(sSound), "weapons/airboat/airboat_gun_lastshot%i.wav", GetRandomInt(1, 2));
	
	PrecacheSound(sSound);
	
	EmitSoundToAll(sSound, iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

public bool Cel_CheckCelCount(int iClient)
{
	int iCount, iLimit;
	
	iCount = Cel_GetCelCount(iClient);
	iLimit = Cel_GetCelLimit();
	
	if (iCount >= iLimit)
	{
		return true;
	}
	
	return false;
}

public bool Cel_CheckOwner(int iClient, int iEntity)
{
	if (g_iOwner[iEntity] == iClient)
	{
		return true;
	}
	
	return false;
}

public bool Cel_CheckPropCount(int iClient)
{
	int iCount, iLimit;
	
	iCount = Cel_GetPropCount(iClient);
	iLimit = Cel_GetPropLimit();
	
	if (iCount >= iLimit)
	{
		return true;
	}
	
	return false;
}

public void Cel_ConVarChanged(ConVar hConVar, const char[] sOldValue, const char[] sNewValue)
{
	Cel_SetCelLimit(GetConVarInt(g_cvCelLimit));
	Cel_SetPropLimit(GetConVarInt(g_cvPropLimit));
}

public void Cel_DissolveEntity(int iEntity)
{
	DispatchKeyValue(iEntity, "targetname", "dissolved");
	
	AcceptEntityInput(g_iEntityDissolver, "dissolve");
}

public void Cel_DownloadFiles()
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

public void Cel_DrawLand(float fFrom[3], float fTo[3], float fLife, int iColor[4], bool bFlat)
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

public bool Cel_FilterPlayer(int iEntity, any iContentsMask)
{
	return iEntity > MaxClients;
}

public char Cel_GetAuthID(int iClient, char sAuthID[64])
{
	strcopy(sAuthID, sizeof(sAuthID), g_sAuthID[iClient]);
}

public int Cel_GetCelCount(int iClient)
{
	return g_iCelCount[iClient];
}

public int Cel_GetCelLimit()
{
	return g_iCelLimit;
}

public float Cel_GetEndPoint(int iClient, float fFinalOrigin[3])
{
	float fEyeAngles[3], fEyeOrigin[3];
	
	GetClientEyeAngles(iClient, fEyeAngles);
	GetClientEyePosition(iClient, fEyeOrigin);
	
	Handle hTraceRay = TR_TraceRayFilterEx(fEyeOrigin, fEyeAngles, MASK_ALL, RayType_Infinite, Cel_FilterPlayer);
	
	if (TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(fFinalOrigin, hTraceRay);
		
		CloseHandle(hTraceRay);
	}
}

public float Cel_GetEntityAngles(int iEntity, float fAngles[3])
{
	GetEntPropVector(iEntity, Prop_Send, "m_angRotation", fAngles);
}

public int Cel_GetEntityColor(int iEntity, int iR, int iG, int iB, int iA)
{
	g_iColor[iEntity][0] = iR, g_iColor[iEntity][1] = iG, g_iColor[iEntity][2] = iB, g_iColor[iEntity][3] = iA;
}

public bool Cel_GetGodMode(int iClient)
{
	return g_bGodMode[iClient];
}

public float Cel_GetEntityOrigin(int iEntity, float fOrigin[3])
{
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fOrigin);
}

public char Cel_GetInternetURL(int iEntity, char sInternetURL[256])
{
	strcopy(sInternetURL, sizeof(sInternetURL), g_sInternetURL[iEntity]);
}

public float Cel_GetMiddleOfBox(const float fMin[3], const float fMax[3], float fMiddle[3])
{
	float fMid[3];
	
	MakeVectorFromPoints(fMin, fMax, fMid);
	
	fMid[0] = fMid[0] / 2.0;
	fMid[1] = fMid[1] / 2.0;
	fMid[2] = fMid[2] / 2.0;
	
	AddVectors(fMin, fMid, fMiddle);
}

public int Cel_GetPropCount(int iClient)
{
	return g_iPropCount[iClient];
}

public int Cel_GetPropLimit()
{
	return g_iPropLimit;
}

public char Cel_GetPropName(int iEntity, char sPropName[64])
{
	strcopy(sPropName, sizeof(sPropName), g_sPropName[iEntity]);
}

public bool Cel_IsClientInsideArea(float fPCords[3], float fbsx, float fbsy, float fbsz, float fbex, float fbey, float fbez)
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

public int Cel_IsClientInsideLand(int iClient)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (!g_bLandDrawing[i])continue;
		
		if (iClient != 0)
		{
			float fClientO[3];
			GetClientAbsOrigin(iClient, fClientO);
			
			if (Cel_IsClientInsideArea(fClientO, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2]))return i;
		} else {
			//if(Cel_IsClientInsideArea(fSource, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2])) return i;
		}
	}
	
	return -1;
}

public int Cel_IsCrosshairInsideLand(int iClient)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (!g_bLandDrawing[i])continue;
		
		if (iClient != 0)
		{
			float fOrigin[3];
			Cel_GetEndPoint(iClient, fOrigin);
			
			if (Cel_IsClientInsideArea(fOrigin, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2]))return i;
		} else {
			//if(Cel_IsClientInsideArea(fSource, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2])) return i;
		}
	}
	
	return -1;
}

public int Cel_IsEntityInsideLand(int iEntity)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (!g_bLandDrawing[i])continue;
		
		if (iEntity != -1 && g_bCelEntity[iEntity])
		{
			float fEntityO[3];
			Cel_GetEntityOrigin(iEntity, fEntityO);
			
			if (Cel_IsClientInsideArea(fEntityO, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2]))return i;
		} else {
			//if(Cel_IsClientInsideArea(fSource, g_fLandOrigin[i][0][0], g_fLandOrigin[i][0][1], g_fLandOrigin[i][0][2], g_fLandOrigin[i][1][0], g_fLandOrigin[i][1][1], g_fLandOrigin[i][1][2])) return i;
		}
	}
	
	return -1;
}

public void Cel_LoadBuild(int iClient, const char[] sBuildName)
{
	char sFileName[PLATFORM_MAX_PATH];
	
	Handle _hFile; float fDelay = 0.10; int iProps = 0; char _sFileBuffer[512];
	
	BuildPath(Path_SM, sFileName, sizeof(sFileName), "data/celmod/saves/%s/%s.txt", g_sAuthID[iClient], sBuildName);
	
	if (FileExists(sFileName, true))
	{
		_hFile = OpenFile(sFileName, "r");
		
		while (ReadFileLine(_hFile, _sFileBuffer, sizeof(_sFileBuffer)))
		{
			Handle hTemp;
			CreateDataTimer(fDelay, Timer_Load, hTemp);
			
			WritePackCell(hTemp, iClient);
			WritePackString(hTemp, _sFileBuffer);
			
			iProps++, fDelay += 0.10;
		}
		
		FlushFile(_hFile);
		CloseHandle(_hFile);
		
		Cel_ReplyToCommand(iClient, "Loading %i props from alias: {green}%s{default}", iProps, sBuildName);
	} else
		Cel_ReplyToCommand(iClient, "That save alias does not exist for this user: {green}%s{default}", sBuildName);
}

public void Cel_NotLooking(int iClient)
{
	CPrintToChat(iClient, "{blue}|CelMod|{default} You are not looking at anything!");
}

public void Cel_NotYours(int iClient)
{
	CPrintToChat(iClient, "{blue}|CelMod|{default} That doesn't belong to you!");
}

public void Cel_PrintToChat(int iClient, const char[] sMessage, any...)
{
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	SetGlobalTransTarget(iClient);
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 3);
	
	CReplaceColorCodes(sBuffer2);
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} %s", sBuffer2);
}

public void Cel_PrintToChatAll(const char[] sMessage, any...)
{
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 2);
	
	CReplaceColorCodes(sBuffer2);
	
	CPrintToChatAll("{blue}|CM|{default} %s", sBuffer2);
}

public void Cel_RemovalBeam(int iClient, int iEntity)
{
	char sSound[96];
	
	float fClientOrigin[3], fEntityOrigin[3];
	
	GetClientAbsOrigin(iClient, fClientOrigin);
	
	Cel_GetEntityOrigin(iEntity, fEntityOrigin);
	
	TE_SetupBeamPoints(fClientOrigin, fEntityOrigin, g_iBeam, g_iHalo, 0, 15, 0.25, 5.0, 5.0, 1, 0.0, g_iGray, 10); TE_SendToAll();
	
	TE_SetupBeamRingPoint(fEntityOrigin, 0.0, 15.0, g_iBeam, g_iHalo, 0, 15, 0.5, 5.0, 0.0, g_iGray, 10, 0); TE_SendToAll();
	
	Format(sSound, sizeof(sSound), "ambient/levels/citadel/weapon_disintegrate%i.wav", GetRandomInt(1, 4));
	
	PrecacheSound(sSound);
	
	EmitAmbientSound(sSound, fEntityOrigin, iEntity, 100, 0, 1.0, 100, 0.0);
}

public void Cel_ReplyToCommand(int iClient, const char[] sMessage, any...)
{
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	SetGlobalTransTarget(iClient);
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 3);
	
	CReplaceColorCodes(sBuffer2);
	
	if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		ReplaceString(sBuffer2, sizeof(sBuffer2), "[tag]", "sm_", true);
		
		CRemoveTags(sBuffer2, sizeof(sBuffer2));
		
		PrintToConsole(iClient, "|CelMod| %s", sBuffer2);
	} else {
		ReplaceString(sBuffer2, sizeof(sBuffer2), "[tag]", "!", true);
		
		CPrintToChat(iClient, "{blue}|CelMod|{default} %s", sBuffer2);
	}
}

public void Cel_SaveBuild(int iClient, const char[] sBuildName)
{
	char sFileName[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH], sSaveString[PLATFORM_MAX_PATH], sModelName[128], sClassname[64], sPropname[64], sSkin[64], sSolid[64];
	float fAngles[3], fEntityOrigin[3], fOrigin[3];
	int iColor[4], iCount = 0;
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/saves/%s", g_sAuthID[iClient]);
	if (!DirExists(sPath))
		CreateDirectory(sPath, 511);
	
	BuildPath(Path_SM, sFileName, sizeof(sFileName), "data/celmod/saves/%s/%s.txt", g_sAuthID[iClient], sBuildName);
	if (FileExists(sFileName, true))
	{
		DeleteFile(sFileName);
		Cel_ReplyToCommand(iClient, "Save already exists: {green}%s{default} ... Overriding old save ...", sBuildName);
	}
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (Cel_CheckOwner(iClient, i))
		{
			int iLand = Cel_IsEntityInsideLand(i);
			
			if (iLand != -1)
			{
				GetEdictClassname(i, sClassname, sizeof(sClassname));
				
				GetEntPropString(i, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
				
				IntToString(GetEntProp(i, Prop_Data, "m_nSkin", 1), sSkin, sizeof(sSkin));
				IntToString(GetEntProp(i, Prop_Send, "m_CollisionGroup", 4, 0), sSolid, sizeof(sSolid));
				
				GetEntityRenderColor(i, iColor[0], iColor[1], iColor[2], iColor[3]);
				
				Cel_GetPropName(i, sPropname);
				
				Cel_GetEntityAngles(i, fAngles);
				Cel_GetEntityOrigin(i, fEntityOrigin);
				
				fOrigin[0] = g_fLandOrigin[iClient][0][0] - fEntityOrigin[0];
				fOrigin[1] = g_fLandOrigin[iClient][0][1] - fEntityOrigin[1];
				fOrigin[2] = g_fLandOrigin[iClient][0][2] - fEntityOrigin[2];
				
				Format(sSaveString, sizeof(sSaveString), "%s %s %s %s %f %f %f %f %f %f %i %i %i %i", sClassname, sModelName, sSkin, sSolid, fOrigin[0], fOrigin[1], fOrigin[2], fAngles[0], fAngles[1], fAngles[2], iColor[0], iColor[1], iColor[2], iColor[3]);
				
				if (StrEqual(sClassname, "cel_internet"))
				{
					Format(sSaveString, sizeof(sSaveString), "%s %s", sSaveString, g_sInternetURL);
				} else if (StrEqual(sClassname, "cel_music"))
				{
					Format(sSaveString, sizeof(sSaveString), "%s %s %s %f %i", sSaveString, sPropname, g_sMusic[i], g_fMusicTime[i], g_bLoop[i] ? 1 : 0);
				} else if (StrEqual(sClassname, "cel_sound"))
				{
					Format(sSaveString, sizeof(sSaveString), "%s %s %s", sSaveString, sPropname, g_sSound[i]);
				} else {
					Format(sSaveString, sizeof(sSaveString), "%s %s", sSaveString, sPropname);
				}
				
				char sBuffer[512];
				
				VFormat(sBuffer, sizeof(sBuffer), sSaveString, 2);
				
				Handle _hFile = OpenFile(sFileName, "a+");
				
				WriteFileLine(_hFile, "%s", sBuffer);
				
				FlushFile(_hFile);
				CloseHandle(_hFile);
			}
			iCount++;
		}
	}
}

public void Cel_SendHudMessage(int iClient, int iChannel, 
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

public void Cel_SetAuthID(int iClient)
{
	GetClientAuthId(iClient, AuthId_Steam2, g_sAuthID[iClient], sizeof(g_sAuthID[]));
	
	ReplaceString(g_sAuthID[iClient], sizeof(g_sAuthID[]), ":", "_");
}

public void Cel_SetCelCount(int iClient, int iCount)
{
	g_iCelCount[iClient] = iCount;
}

public void Cel_SetCelLimit(int iLimit)
{
	g_iCelLimit = iLimit;
}

public void Cel_SetEntityColor(int iEntity, int iR, int iG, int iB, int iA)
{
	SetEntityRenderColor(iEntity, iR, iG, iB, iA);
	SetEntityRenderMode(iEntity, RENDER_TRANSALPHA);
	
	g_iColor[iEntity][0] = iR, g_iColor[iEntity][1] = iG, g_iColor[iEntity][2] = iB, g_iColor[iEntity][3] = iA;
}

public void Cel_SetGodMode(int iClient, bool bGodMode)
{
	if (bGodMode)
	{
		SetEntProp(iClient, Prop_Data, "m_takedamage", 0, 1);
	} else {
		SetEntProp(iClient, Prop_Data, "m_takedamage", 2, 1);
	}
	
	g_bGodMode[iClient] = bGodMode;
}

public void Cel_SetInternetURL(int iEntity, const char[] sURL)
{
	Format(g_sInternetURL[iEntity], sizeof(g_sInternetURL[]), sURL);
}

public void Cel_SetPropCount(int iClient, int iCount)
{
	g_iPropCount[iClient] = iCount;
}

public void Cel_SetPropLimit(int iLimit)
{
	g_iPropLimit = iLimit;
}

public void Cel_SetPropName(int iEntity, const char[] sPropName)
{
	Format(g_sPropName[iEntity], sizeof(g_sPropName[]), sPropName);
}

public void Cel_SpawnDoor(int iClient, char[] sSkin, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
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
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	Cel_SetPropName(iEntity, "door");
	
	g_bCelEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bSolid[iEntity] = true;
}

public void Cel_SpawnInternet(int iClient, char[] sURL, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
{
	int iEntity = CreateEntityByName("prop_physics_multiplayer");
	
	PrecacheModel("models/props_lab/monitor02.mdl");
	
	DispatchKeyValue(iEntity, "classname", "cel_internet");
	DispatchKeyValue(iEntity, "model", "models/props_lab/monitor02.mdl");
	DispatchKeyValue(iEntity, "skin", "2");
	
	DispatchSpawn(iEntity);
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	DispatchKeyValue(iEntity, "skin", "1");
	
	Cel_SetInternetURL(iEntity, sURL);
	
	g_iOwner[iEntity] = iClient;
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	AcceptEntityInput(iEntity, "disablemotion");
	
	g_bCelEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bCanCopy[iEntity] = false;
	
	g_bMotion[iEntity] = false;
	
	g_bSolid[iEntity] = true;
}

public void Cel_SpawnMusic(int iClient, char[] sAlias, char[] sSound, bool bLoop, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
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
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	Cel_SetPropName(iEntity, sAlias);
	
	AcceptEntityInput(iEntity, "disablemotion");
	
	g_bCelEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bCanCopy[iEntity] = false;
	
	g_bLoop[iEntity] = bLoop;
	
	g_bMotion[iEntity] = false;
	
	g_bSolid[iEntity] = true;
}

public void Cel_SpawnProp(int iClient, char[] sAlias, char[] sModel, char[] sSpawnMode, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
{
	int iEntity = CreateEntityByName(sSpawnMode);
	
	PrecacheModel(sModel);
	
	DispatchKeyValue(iEntity, "classname", sSpawnMode);
	DispatchKeyValue(iEntity, "model", sModel);
	
	DispatchSpawn(iEntity);
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	g_iOwner[iEntity] = iClient;
	
	Cel_AddToPropCount(iClient);
	
	Cel_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	Cel_SetPropName(iEntity, sAlias);
	
	g_bCelEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bCanCopy[iEntity] = true;
	
	g_bMotion[iEntity] = true;
	
	g_bSolid[iEntity] = true;
}

public void Cel_SpawnSound(int iClient, char[] sAlias, char[] sSound, float fOrigin[3], float fAngles[3], int iR, int iG, int iB, int iA)
{
	int iEntity = CreateEntityByName("prop_physics_override");
	
	PrecacheModel(g_sSoundModel);
	
	DispatchKeyValue(iEntity, "classname", "cel_sound");
	DispatchKeyValue(iEntity, "model", g_sSoundModel);
	
	DispatchSpawn(iEntity);
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
	
	Format(g_sSound[iEntity], sizeof(g_sSound[]), sSound);
	
	g_iOwner[iEntity] = iClient;
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetEntityColor(iEntity, iR, iG, iB, iA);
	
	Cel_SetPropName(iEntity, sAlias);
	
	AcceptEntityInput(iEntity, "disablemotion");
	
	g_bCelEntity[iEntity] = true;
	
	g_bFadeColor[iEntity] = false;
	
	g_bCanCopy[iEntity] = false;
	
	g_bMotion[iEntity] = false;
	
	g_bSolid[iEntity] = true;
}

public void Cel_SubFromCelCount(int iClient)
{
	int iCount = Cel_GetCelCount(iClient);
	
	iCount--; Cel_SetCelCount(iClient, iCount);
}

public void Cel_SubFromPropCount(int iClient)
{
	int iCount = Cel_GetPropCount(iClient);
	
	iCount--; Cel_SetPropCount(iClient, iCount);
}

//Timers:
/*
public Action Timer_FadeColors(Handle hTimer, Handle hPack)
{
	int iEntity, iFirstColor[3], iOriginalColor[4], iSecondColor[3];
	
	ResetPack(hPack);
	
	iEntity = ReadPackCell(hPack);
	
	iFirstColor[0] = ReadPackCell(hPack);
	iFirstColor[1] = ReadPackCell(hPack);
	iFirstColor[2] = ReadPackCell(hPack);
	
	iSecondColor[0] = ReadPackCell(hPack);
	iSecondColor[1] = ReadPackCell(hPack);
	iSecondColor[2] = ReadPackCell(hPack);
	
	Cel_GetEntityColor(iEntity, iOriginalColor[0], iOriginalColor[1], iOriginalColor[2], iOriginalColor[3]);
}*/

/*public Action Timer_Rainbow(Handle hTimer)
{
	int iColor[4], iCurrentColor[3];
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if(g_bIsRainbow[i])
		{
			GetEntityRenderColor(i, iColor[0], iColor[1], iColor[2], iColor[3]);
			
			switch(g_iRainbowSection[i])
			{
				case 0:
				{
					iCurrentColor[0] = 255;
					iCurrentColor[1] = iColor[1]++;
					iCurrentColor[2] = 0;
					
					if(iCurrentColor[1] == 128)
						g_iRainbowSection[i] = 1;
						
					Cel_SetEntityColor(i, iCurrentColor[0], iCurrentColor[1], iCurrentColor[2], 255);
				}
				case 1:
				{
					iCurrentColor[0] = 255;
					iCurrentColor[1] = iColor[1]++;
					iCurrentColor[2] = 0;
					
					if(iCurrentColor[1] == 255)
						g_iRainbowSection[i] = 2;
						
					Cel_SetEntityColor(i, iCurrentColor[0], iCurrentColor[1], iCurrentColor[2], 255);
				}
				case 2:
				{
					iCurrentColor[0] = iColor[0]--;
					iCurrentColor[1] = 255;
					iCurrentColor[2] = 0;
					
					if(iCurrentColor[0] == 0)
						g_iRainbowSection[i] = 3;
				
					Cel_SetEntityColor(i, iCurrentColor[0], iCurrentColor[1], iCurrentColor[2], 255);
				}
				case 3:
				{
					iCurrentColor[0] = 0;
					iCurrentColor[1] = iColor[1]--;
					iCurrentColor[2] = iColor[2]++;
					
					if(iCurrentColor[1] == 0)
						iCurrentColor[1] = 0;
					
					if(iCurrentColor[1] == 0 && iCurrentColor[2] == 255)
						g_iRainbowSection[i] = 4;
						
						Cel_SetEntityColor(i, iCurrentColor[0], iCurrentColor[1], iCurrentColor[2], 255);
				}
				case 4:
				{
					iCurrentColor[0] = iColor[0]++;
					iCurrentColor[1] = iColor[1]++;
					iCurrentColor[2] = iColor[2]--;
					
					if(iCurrentColor[0] == 12)
						iCurrentColor[0] = 12;
						
					if(iCurrentColor[1] == 56)
						iCurrentColor[1] = 56;
					
					if(iCurrentColor[0] == 12 && iCurrentColor[1] == 56 && iCurrentColor[2] == 128)
						g_iRainbowSection[i] = 5;
						
						Cel_SetEntityColor(i, iCurrentColor[0], iCurrentColor[1], iCurrentColor[2], 255);
				}
				case 5:
				{
					iCurrentColor[0] = iColor[0]++;
					iCurrentColor[1] = iColor[1]--;
					iCurrentColor[2] = iColor[2]++;
					
					if(iCurrentColor[0] == 128)
						iCurrentColor[0] = 128;
						
					if(iCurrentColor[1] == 0)
						iCurrentColor[1] = 0;
					
					if(iCurrentColor[0] == 128 && iCurrentColor[1] == 0 && iCurrentColor[2] == 255)
						g_iRainbowSection[i] = 6;
						
						Cel_SetEntityColor(i, iCurrentColor[0], iCurrentColor[1], iCurrentColor[2], 255);
				}
				case 6:
				{
					iCurrentColor[0] = iColor[0]++;
					iCurrentColor[1] = 0;
					iCurrentColor[2] = iColor[2]--;
					
					if(iCurrentColor[0] == 255)
						iCurrentColor[0] = 255;
						
					if(iCurrentColor[2] == 0)
						iCurrentColor[2] = 0;
					
					if(iCurrentColor[0] == 255 && iCurrentColor[2] == 0)
						g_iRainbowSection[i] = 0;
						
						Cel_SetEntityColor(i, iCurrentColor[0], iCurrentColor[1], iCurrentColor[2], 255);
				}
			}
		}
	}
}*/

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
			
			Cel_DrawLand(fLandPos, g_fLandOrigin[i][1], 0.1, g_iClientColor[i], false);
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

public Action Timer_InLand(Handle hTimer)
{
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientConnected(i) && g_bConnected[i])
		{
			int iLand = Cel_IsClientInsideLand(i);
			
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

public Action Timer_Load(Handle hTimer, Handle hPack)
{
	/*ResetPack(hPack);
	int iClient = ReadPackCell(hPack);
	
	char sBuffer[256], sBuffers[12][256]; int iColor[4];
	ReadPackString(hPack, sBuffer, sizeof(sBuffer));
	
	ExplodeString(sbuffer, " ", sBuffers, 12, 255);
	
	decl Float:fOrigin[3], Float:fAngles[3], String:sTarget[64], String:sAuth[64];
	
	new iEntity = CreateEntityByName("prop_physics_override");
	
	GetClientAuthString(iClient, sAuth, sizeof(sAuth));
	
	Format(sTarget, sizeof(sTarget), "SimpleBuild:%s", sAuth);
	DispatchKeyValue(iEntity, "targetname", sTarget);
	
	PrecacheModel(sBuffers[0]);
	DispatchKeyValue(iEntity, "model", sBuffers[0]);
	
	fOrigin[0] = StringToFloat(sBuffers[1]);
	fOrigin[1] = StringToFloat(sBuffers[2]);
	fOrigin[2] = StringToFloat(sBuffers[3]);
	
	fAngles[0] = StringToFloat(sBuffers[4]);
	fAngles[1] = StringToFloat(sBuffers[5]);
	fAngles[2] = StringToFloat(sBuffers[6]);
	
	iColor[0] = StringToInt(sBuffers[8]);
	iColor[1] = StringToInt(sBuffers[9]);
	iColor[2] = StringToInt(sBuffers[10]);
	
	g_iPreviousColor[iEntity][0] = iColor[0];
	g_iPreviousColor[iEntity][1] = iColor[1];
	g_iPreviousColor[iEntity][2] = iColor[2];
	g_iPreviousColor[iEntity][3] = StringToInt(sBuffers[11]);

	DispatchKeyValue(iEntity, "rendermode", "5");
	DispatchKeyValue(iEntity, "renderamt", sBuffers[11]);

	if (!DispatchSpawn(iEntity)) LogError("didn't spawn");

	SetEntityRenderColor(iEntity, iColor[0], iColor[1], iColor[2], StringToInt(sBuffers[11]));
	SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", StringToInt(sBuffers[7]), 4, 0);

	AcceptEntityInput(iEntity, "DisableMotion");
	
	g_iOwner[iEntity] = iClient;
	g_iPropCount[iClient] += 1;
	
	TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);*/
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
				Cel_GetEndPoint(i, fOrigin);
				
				/*NormalizeVector(
				
				float fDistance = GetVectorDistance(g_fLandOrigin[i][0], fOrigin, false);
				
				if(fDistance == 100)
				{
					fRealOrigin = fOrigin;
					
					bBeyondLimit = true;
				}
				
				if(bBeyondLimit)
				{
					g_fLandOrigin[i][1] = fRealOrigin;
				}else{
					g_fLandOrigin[i][1] = fOrigin;
				}*/
				
				g_fLandOrigin[i][1] = fOrigin;
			}
		}
	}
}

public Action Timer_Remove(Handle hTimer, any iEntity)
{
	if (IsValidEntity(iEntity))
	{
		g_bCanCopy[iEntity] = false;
		
		g_bCelEntity[iEntity] = false;
		
		StopSound(iEntity, 2, g_sSound[iEntity]);
		StopSound(iEntity, 3, g_sMusic[iEntity]);
		
		g_bLoop[iEntity] = false;
		g_bPlaying[iEntity] = false;
		
		AcceptEntityInput(iEntity, "kill");
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
				
				Cel_ReplyToCommand(iParam1, "Set Land Gravity to {green}low{default}.");
			} else if (StrEqual(sInfo, "Normal"))
			{
				g_fLandGravity[iParam1] = 1.0;
				
				Cel_ReplyToCommand(iParam1, "Set Land Gravity to {green}normal{default}.");
			} else if (StrEqual(sInfo, "High"))
			{
				g_fLandGravity[iParam1] = 2.0;
				
				Cel_ReplyToCommand(iParam1, "Set Land Gravity to {green}high{default}.");
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

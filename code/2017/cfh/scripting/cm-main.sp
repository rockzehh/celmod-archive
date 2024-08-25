#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <celmod>
#include <morecolors>
#include <geoip>
#include <s-a-s>
#include <buttondetector>

#pragma newdecls required

#define VERSION "1.1.4"
#define MAX_ENTITIES 2048

bool g_bEntity[MAX_ENTITIES + 1];
bool g_bFrozen[MAX_ENTITIES + 1];
bool g_bPlayer[MAX_ENTITIES + 1];
bool g_bServerChat[MAXPLAYERS + 1];

char g_sAuthID[MAXPLAYERS + 1][64];
char g_sColors[PLATFORM_MAX_PATH];
char g_sDownloads[PLATFORM_MAX_PATH];
char g_sEmpty[MAX_MESSAGE_LENGTH] = "";
char g_sPlayerTag[MAXPLAYERS + 1][64];
char g_sPropname[MAX_ENTITIES + 1][64];
char g_sSpawns[PLATFORM_MAX_PATH];

ConVar g_cvCelLimit;
ConVar g_cvPropLimit;

float g_fZero[3] =  { 0.0, 0.0, 0.0 };

Handle g_hHudTimer;

int g_iBeam;
int g_iBlue[4] =  { 0, 0, 255, 175 };
int g_iCelCount[MAXPLAYERS + 1];
int g_iCelLimit;
int g_iClientColor[MAXPLAYERS + 1][4];
int g_iCoins[MAXPLAYERS + 1];
int g_iColor[MAX_ENTITIES + 1][4];
int g_iEntityRemover;
int g_iGray[4] =  { 255, 255, 255, 300 };
int g_iGreen[4] =  { 0, 255, 0, 175 };
int g_iHalo;
int g_iLandColor[MAXPLAYERS + 1][4];
int g_iLaser;
int g_iOrange[4] =  { 255, 128, 0, 175 };
int g_iOwner[MAX_ENTITIES + 1];
int g_iPhys;
int g_iPropCount[MAXPLAYERS + 1];
int g_iPropLimit;
int g_iRed[4] =  { 255, 0, 0, 175 };
int g_iWhite[4] =  { 255, 255, 255, 175 };
int g_iYellow[4] =  { 255, 255, 0, 175 };

public Plugin myinfo = 
{
	name = "|CelMod|", 
	author = "FusionLock", 
	description = "Your favorite building plugin you haven't heard of yet.", 
	version = VERSION, 
	url = "https://bitbucket.org/zaachhhh/celmod-cels-fun-house"
};

public void OnPluginStart()
{
	BuildPath(Path_SM, g_sColors, sizeof(g_sColors), "data/cm-cfh/colors.txt");
	if (!FileExists(g_sColors))
		SetFailState("|CelMod| 'colors.txt' cannot be found.");
	
	BuildPath(Path_SM, g_sDownloads, sizeof(g_sDownloads), "data/cm-cfh/downloads.txt");
	if (FileExists(g_sDownloads))
		CelMod_DownloadFiles();
	
	BuildPath(Path_SM, g_sSpawns, sizeof(g_sSpawns), "data/cm-cfh/spawns.txt");
	if (!FileExists(g_sSpawns))
		SetFailState("|CelMod| 'spawns.txt' cannot be found.");
	
	CreateConVar("celmod_version", VERSION, "The version of |CelMod| that the server is running.", FCVAR_NOTIFY);
	g_cvCelLimit = CreateConVar("cm_cel_limit", "25", "The max number of cels you can spawn", FCVAR_NOTIFY);
	g_cvPropLimit = CreateConVar("cm_prop_limit", "150", "The max number of props you can spawn.", FCVAR_NOTIFY);
	
	g_iCelLimit = GetConVarInt(g_cvCelLimit);
	g_iPropLimit = GetConVarInt(g_cvPropLimit);
	
	HookConVarChange(g_cvCelLimit, CelMod_ConVarChanged);
	HookConVarChange(g_cvPropLimit, CelMod_ConVarChanged);
	
	HookEvent("player_connect", Event_Connect, EventHookMode_Pre);
	HookEvent("player_death", Event_Death, EventHookMode_Post);
	HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
	
	AddCommandListener(Handle_Chat, "say");
	AddCommandListener(Handle_Chat, "say_team");
	
	RegConsoleCmd("sm_color", Command_Color, "Colors an entity.");
	RegConsoleCmd("sm_del", Command_Delete, "Removes an entity.");
	RegConsoleCmd("sm_delete", Command_Delete, "Removes an entity.");
	RegConsoleCmd("sm_serverchat", Command_ServerChat, "Enables/Disables talking in server chat.");
	RegConsoleCmd("sm_freeze", Command_Freeze, "Disables motion on an entity.");
	RegConsoleCmd("sm_remove", Command_Delete, "Removes an entity.");
	RegConsoleCmd("sm_spawn", Command_Spawn, "Spawns an prop by alias.");
	RegConsoleCmd("sm_stand", Command_Straighten, "Resets a entities angles.");
	RegConsoleCmd("sm_straight", Command_Straighten, "Resets a entities angles.");
	RegConsoleCmd("sm_straighten", Command_Straighten, "Resets a entities angles.");
	RegConsoleCmd("sm_unfreeze", Command_UnFreeze, "Enables motion on an entity.");
}

public void OnClientAuthorized(int iClient, const char[] sAuth)
{
	char sCountry[45], sIP[64];
	
	GetClientAuthId(iClient, AuthId_Steam2, g_sAuthID[iClient], sizeof(g_sAuthID[]), true);
	GetClientIP(iClient, sIP, sizeof(sIP), true);
	GeoipCountry(sIP, sCountry, sizeof(sCountry));
	
	CPrintToChatAll("{green}[+]{default} Player {green}%N{default} connected from {green}%s{default}", iClient, sCountry);
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			ClientCommand(i, "play npc/metropolice/vo/on1.wav");
		}
	}
}

public void OnClientPutInServer(int iClient)
{
	Format(g_sPlayerTag[iClient], sizeof(g_sPlayerTag[]), SAS_CheckAdmin(iClient) ? "Admin" : "Player");
	
	CelMod_ChooseHudColor(iClient);
	CelMod_ChooseLandColor(iClient);
	
	g_bPlayer[iClient] = true;
	
	g_bServerChat[iClient] = false;
	
	g_iCelCount[iClient] = 0;
	g_iPropCount[iClient] = 0;
}

public void OnClientDisconnect(int iClient)
{
	g_bPlayer[iClient] = false;
	
	g_bServerChat[iClient] = false;
	
	g_iCelCount[iClient] = 0;
	g_iPropCount[iClient] = 0;
	
	Format(g_sAuthID[iClient], sizeof(g_sAuthID[]), g_sEmpty);
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (CelMod_CheckOwner(iClient, i))
		{
			g_bFrozen[i] = false;
			g_bEntity[i] = false;
			
			CreateTimer(0.10, Timer_DisRemove, i);
		}
	}
	
	CPrintToChatAll("{red}[-]{default} Player {green}%N{default} disconnected", iClient);
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			ClientCommand(i, "play npc/metropolice/vo/off1.wav");
		}
	}
}

public void OnMapStart()
{
	g_iEntityRemover = CreateEntityByName("env_entity_dissolver");
	
	DispatchKeyValue(g_iEntityRemover, "dissolvetype", "3");
	DispatchKeyValue(g_iEntityRemover, "magnitude", "250");
	DispatchKeyValue(g_iEntityRemover, "target", "cm_entity_removal");
	DispatchKeyValue(g_iEntityRemover, "targetname", "celmod_entity_remover");
	
	DispatchSpawn(g_iEntityRemover);
	
	g_iHalo = PrecacheModel("materials/sprites/halo01.vmt", true);
	g_iBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_iPhys = PrecacheModel("materials/sprites/physbeam.vmt", true);
	g_iLaser = PrecacheModel("materials/sprites/laser.vmt", true);
	
	g_hHudTimer = CreateTimer(0.1, Timer_Hud, _, TIMER_REPEAT);
}

public void OnMapEnd()
{
	g_iEntityRemover = -1;
	
	CloseHandle(g_hHudTimer);
}

public void CelMod_ConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	g_iCelLimit = GetConVarInt(g_cvCelLimit);
	g_iPropLimit = GetConVarInt(g_cvPropLimit);
}

public bool CelMod_FilterPlayer(int iEntity, any aContentsMask)
{
	return iEntity > MaxClients;
}

public void SAS_OnAdminChanged(int iClient, int iLevel)
{
	Format(g_sPlayerTag[iClient], sizeof(g_sPlayerTag[]), SAS_CheckAdmin(iClient) ? "Admin" : "Player");
}

//Plugin Commands:
public Action Command_Color(int iClient, int iArgs)
{
	char sColor[128], sColors[3][64], sColorString[128], sOption[64];
	
	if (iArgs < 1)
	{
		CelMod_ReplyToCommand(iClient, "Usage: [cm]color <color> <all|hud|land>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor, sizeof(sColor));
	
	GetCmdArg(2, sOption, sizeof(sOption));
	
	KeyValues kvColors = new KeyValues("Colors");
	
	kvColors.ImportFromFile(g_sColors);
	
	kvColors.JumpToKey("Names");
	
	kvColors.GetString(sColor, sColorString, sizeof(sColorString), "null");
	
	kvColors.Rewind();
	
	kvColors.Close();
	
	if (StrEqual(sColorString, "null"))
	{
		CelMod_ReplyToCommand(iClient, "Color {green}%s{default} not found!", sColor);
		CelMod_ReplyToCommand(iClient, "Type {green}!colors{default} to see the color list.");
		return Plugin_Handled;
	}
	
	ExplodeString(sColorString, "^", sColors, 3, sizeof(sColors[]));
	
	if (StrEqual(sOption, "all"))
	{
		for (int i = 0; i < GetMaxEntities(); i++)
		{
			if (CelMod_CheckOwner(iClient, i))
			{
				CelMod_SetEntityColor(i, StringToInt(sColors[0]), StringToInt(sColors[1]), StringToInt(sColors[2]), g_iColor[i][3]);
			}
		}
		
		CelMod_ReplyToCommand(iClient, "Set all entities to the color {green}%s{default}.", sColor);
		
		return Plugin_Handled;
	} else if (StrEqual(sOption, "hud"))
	{
		g_iClientColor[iClient][0] = StringToInt(sColors[0]), g_iClientColor[iClient][1] = StringToInt(sColors[1]), g_iClientColor[iClient][2] = StringToInt(sColors[2]), g_iClientColor[iClient][3] = 255;
		
		CelMod_ReplyToCommand(iClient, "Set hud color to {green}%s{default}.", sColor);
		
		return Plugin_Handled;
	} else if (StrEqual(sOption, "land"))
	{
		g_iLandColor[iClient][0] = StringToInt(sColors[0]), g_iLandColor[iClient][1] = StringToInt(sColors[1]), g_iLandColor[iClient][2] = StringToInt(sColors[2]), g_iLandColor[iClient][3] = 255;
		
		CelMod_ReplyToCommand(iClient, "Set land color to {green}%s{default}.", sColor);
		
		return Plugin_Handled;
	} else if (StrEqual(sOption, ""))
	{
		int iEntity = GetClientAimTarget(iClient, false);
		
		if (iEntity == -1)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (g_bEntity[iEntity] == false)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (CelMod_CheckOwner(iClient, iEntity))
		{
			CelMod_SetEntityColor(iEntity, StringToInt(sColors[0]), StringToInt(sColors[1]), StringToInt(sColors[2]), g_iColor[iEntity][3]);
			
			CelMod_ChangeBeam(iClient);
			
			CelMod_ReplyToCommand(iClient, "Changed color to {green}%s{default}", sColor);
		} else {
			CelMod_DontOwn(iClient);
			return Plugin_Handled;
		}
		
		return Plugin_Handled;
	} else {
		CelMod_ReplyToCommand(iClient, "Usage: [cm]color <color> <all|hud|land>");
		return Plugin_Handled;
	}
}

public Action Command_Delete(int iClient, int iArgs)
{
	char sClassname[64], sOption[64];
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	if (StrEqual(sOption, "all"))
	{
		for (int i = 0; i < GetMaxEntities(); i++)
		{
			if (CelMod_CheckOwner(iClient, i))
			{
				g_bFrozen[i] = false;
				g_bEntity[i] = false;
				
				g_iCelCount[iClient] = 0;
				g_iPropCount[iClient] = 0;
				
				CelMod_RemoveEntity(i);
			}
		}
		
		CelMod_ReplyToCommand(iClient, "Removed all entities.");
		
		return Plugin_Handled;
	} else if (StrEqual(sOption, ""))
	{
		int iEntity = GetClientAimTarget(iClient, false);
		
		if (iEntity == -1)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (g_bEntity[iEntity] == false)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (CelMod_CheckOwner(iClient, iEntity))
		{
			GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
			
			if (StrContains(sClassname, "cel_") != -1)
			{
				g_iCelCount[iClient]--;
			} else {
				g_iPropCount[iClient]--;
			}
			
			g_bFrozen[iEntity] = false;
			g_bEntity[iEntity] = false;
			
			CelMod_RemoveEntity(iEntity);
			
			CelMod_RemoveBeam(iClient);
			
			CelMod_ReplyToCommand(iClient, "Removed entity {green}#%i{default}", iEntity);
		} else {
			CelMod_DontOwn(iClient);
			return Plugin_Handled;
		}
		
		return Plugin_Handled;
	} else {
		CelMod_ReplyToCommand(iClient, "Usage: [cm]delete <all>");
		return Plugin_Handled;
	}
}

public Action Command_ServerChat(int iClient, int iArgs)
{
	if (SAS_CheckAdminLevel(iClient, 3))
	{
		CelMod_ReplyToCommand(iClient, "You cannot use this command!");
		return Plugin_Handled;
	}
	
	if (g_bServerChat[iClient])
	{
		g_bServerChat[iClient] = false;
		
		CelMod_PrintToChat(iClient, "Disabled talking in server chat.");
	} else {
		g_bServerChat[iClient] = true;
		
		CelMod_PrintToChat(iClient, "Enabled talking in server chat.");
	}
	
	return Plugin_Handled;
}

public Action Command_Freeze(int iClient, int iArgs)
{
	char sOption[64];
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	if (StrEqual(sOption, "all"))
	{
		for (int i = 0; i < GetMaxEntities(); i++)
		{
			if (CelMod_CheckOwner(iClient, i))
			{
				CelMod_SetMotion(i, true);
			}
		}
		
		CelMod_ReplyToCommand(iClient, "Froze all entities.");
		
		return Plugin_Handled;
	} else if (StrEqual(sOption, ""))
	{
		int iEntity = GetClientAimTarget(iClient, false);
		
		if (iEntity == -1)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (g_bEntity[iEntity] == false)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (CelMod_CheckOwner(iClient, iEntity))
		{
			CelMod_SetMotion(iEntity, true);
			
			CelMod_ChangeBeam(iClient);
			
			CelMod_ReplyToCommand(iClient, "Froze entity {green}#%i{default}", iEntity);
		} else {
			CelMod_DontOwn(iClient);
			return Plugin_Handled;
		}
		
		return Plugin_Handled;
	} else {
		CelMod_ReplyToCommand(iClient, "Usage: [cm]freeze <all>");
		return Plugin_Handled;
	}
}

public Action Command_Spawn(int iClient, int iArgs)
{
	char sAlias[128], sModel[128], sProp[128], sSpawnSplit[2][128], sSpawnString[256];
	float fAbsAngles[3], fAngles[3], fFinalOrigin[3], fOrigin[3];
	
	if (iArgs < 1)
	{
		CelMod_ReplyToCommand(iClient, "[cm]spawn <alias>");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	
	if (g_iPropCount[iClient] >= g_iPropLimit)
	{
		CelMod_ReplyToCommand(iClient, "You have hit the prop limit! [{blue}%i{default}/{blue}%i{default}]", g_iPropCount[iClient], g_iPropLimit);
		return Plugin_Handled;
	}
	
	KeyValues kvProps = new KeyValues("Props");
	
	kvProps.ImportFromFile(g_sSpawns);
	
	kvProps.JumpToKey("Models");
	
	kvProps.GetString(sAlias, sSpawnString, sizeof(sSpawnString), "null");
	
	kvProps.Rewind();
	
	if (StrEqual(sSpawnString, "null"))
	{
		CelMod_ReplyToCommand(iClient, "Prop {green}%s{default} not found!", sAlias);
		CelMod_ReplyToCommand(iClient, "Type {green}!props{default} to see the prop list.");
		return Plugin_Handled;
	}
	
	ExplodeString(sSpawnString, "^", sSpawnSplit, 2, sizeof(sSpawnSplit[]));
	
	strcopy(sProp, sizeof(sProp), sSpawnSplit[0]);
	strcopy(sModel, sizeof(sModel), sSpawnSplit[1]);
	
	int iEntity = CreateEntityByName(sProp);
	
	PrecacheModel(sModel);
	
	DispatchKeyValue(iEntity, "model", sModel);
	
	DispatchSpawn(iEntity);
	
	GetClientAbsAngles(iClient, fAbsAngles);
	GetClientEyeAngles(iClient, fAngles);
	GetClientEyePosition(iClient, fOrigin);
	
	Handle hTraceRay = TR_TraceRayFilterEx(fOrigin, fAngles, MASK_SOLID, RayType_Infinite, CelMod_FilterPlayer);
	if (TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(fFinalOrigin, hTraceRay);
		
		CloseHandle(hTraceRay);
	}
	
	TeleportEntity(iEntity, fFinalOrigin, fAbsAngles, NULL_VECTOR);
	
	g_iOwner[iEntity] = iClient;
	
	g_bEntity[iEntity] = true;
	
	g_iPropCount[iClient]++;
	
	CelMod_SetMotion(iEntity, false);
	
	CelMod_SetEntityColor(iEntity, 255, 255, 255, 255);
	
	Format(g_sPropname[iEntity], sizeof(g_sPropname[]), sAlias);
	
	return Plugin_Handled;
}

public Action Command_Straighten(int iClient, int iArgs)
{
	char sOption[64];
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	if (StrEqual(sOption, "all"))
	{
		for (int i = 0; i < GetMaxEntities(); i++)
		{
			if (CelMod_CheckOwner(iClient, i))
			{
				TeleportEntity(i, NULL_VECTOR, g_fZero, NULL_VECTOR);
			}
		}
		
		CelMod_ReplyToCommand(iClient, "Straightened all entities.");
		
		return Plugin_Handled;
	} else if (StrEqual(sOption, ""))
	{
		int iEntity = GetClientAimTarget(iClient, false);
		
		if (iEntity == -1)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (g_bEntity[iEntity] == false)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (CelMod_CheckOwner(iClient, iEntity))
		{
			TeleportEntity(iEntity, NULL_VECTOR, g_fZero, NULL_VECTOR);
			
			CelMod_ReplyToCommand(iClient, "Straightened entity {green}#%i{default}", iEntity);
		} else {
			CelMod_DontOwn(iClient);
			return Plugin_Handled;
		}
		
		return Plugin_Handled;
	} else {
		CelMod_ReplyToCommand(iClient, "Usage: [cm]straighten <all>");
		return Plugin_Handled;
	}
}

public Action Command_UnFreeze(int iClient, int iArgs)
{
	char sOption[64];
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	if (StrEqual(sOption, "all"))
	{
		for (int i = 0; i < GetMaxEntities(); i++)
		{
			if (CelMod_CheckOwner(iClient, i))
			{
				CelMod_SetMotion(i, false);
			}
		}
		
		CelMod_ReplyToCommand(iClient, "Unfroze all entities.");
		
		return Plugin_Handled;
	} else if (StrEqual(sOption, ""))
	{
		int iEntity = GetClientAimTarget(iClient, false);
		
		if (iEntity == -1)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (g_bEntity[iEntity] == false)
		{
			CelMod_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		if (CelMod_CheckOwner(iClient, iEntity))
		{
			CelMod_SetMotion(iEntity, false);
			
			CelMod_ChangeBeam(iClient);
			
			CelMod_ReplyToCommand(iClient, "Unfroze entity {green}#%i{default}", iEntity);
		} else {
			CelMod_DontOwn(iClient);
			return Plugin_Handled;
		}
		
		return Plugin_Handled;
	} else {
		CelMod_ReplyToCommand(iClient, "Usage: [cm]unfreeze <all>");
		return Plugin_Handled;
	}
}

public Action Handle_Chat(int iClient, char[] sCommand, int iArgs)
{
	char sMessage[256], sNickname[128], sName[128];
	
	GetCmdArgString(sMessage, sizeof(sMessage));
	
	StripQuotes(sMessage);
	
	CRemoveTags(sMessage, sizeof(sMessage));
	
	if (IsChatTrigger())
	{
		return Plugin_Handled;
	} else if (g_bServerChat[iClient])
	{
		CelMod_PrintToChatAll(sMessage);
		
		return Plugin_Handled;
	} else {
		GetClientName(iClient, sName, sizeof(sName));
		SAS_GetNickname(iClient, sNickname, sizeof(sNickname));
		
		CRemoveTags(sName, sizeof(sName));
		
		if (StrEqual(sNickname, "null"))
		{
			if (SAS_CheckAdmin(iClient))
			{
				int iAdminLevel = SAS_GetAdmin(iClient);
				
				if (iAdminLevel == 1 || iAdminLevel == 2)
				{
					Format(sMessage, sizeof(sMessage), "[{yellow}Admin{default}] %s: %s", sName, sMessage);
				} else if (iAdminLevel == 3) {
					Format(sMessage, sizeof(sMessage), "[{yellow}Co-Owner{default}] %s: %s", sName, sMessage);
				}
			} else {
				Format(sMessage, sizeof(sMessage), "%s: %s", sName, sMessage);
			}
		} else {
			if (SAS_CheckAdmin(iClient))
			{
				int iAdminLevel = SAS_GetAdmin(iClient);
				
				if (iAdminLevel == 1 || iAdminLevel == 2)
				{
					Format(sMessage, sizeof(sMessage), "[{yellow}Admin{default}] %s: %s", sNickname, sMessage);
				} else if (iAdminLevel == 3) {
					Format(sMessage, sizeof(sMessage), "[{yellow}Co-Owner{default}] %s: %s", sNickname, sMessage);
				}
			} else {
				Format(sMessage, sizeof(sMessage), "%s: %s", sNickname, sMessage);
			}
		}
		
		CPrintToChatAll(sMessage);
		
		return Plugin_Handled;
	}
}

//Plugin Stocks:
void CelMod_ChangeBeam(int iClient)
{
	char sSound[64];
	float fAbsOrigin[3], fAngles[3], fFinalOrigin[3], fOrigin[3];
	
	GetClientAbsOrigin(iClient, fAbsOrigin);
	GetClientEyeAngles(iClient, fAngles);
	GetClientEyePosition(iClient, fOrigin);
	
	Handle hTraceRay = TR_TraceRayFilterEx(fOrigin, fAngles, MASK_ALL, RayType_Infinite, CelMod_FilterPlayer);
	if (TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(fFinalOrigin, hTraceRay);
		
		CloseHandle(hTraceRay);
	}
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	TE_SetupBeamPoints(fAbsOrigin, fFinalOrigin, g_iPhys, g_iHalo, 0, 15, 0.1, 3.0, 3.0, 1, 0.0, g_iWhite, 10);
	TE_SendToAll();
	
	TE_SetupSparks(fFinalOrigin, g_fZero, 3, 2);
	TE_SendToAll();
	
	Format(sSound, sizeof(sSound), "weapons/airboat/airboat_gun_lastshot%i.wav", GetRandomInt(1, 2));
	
	PrecacheSound(sSound);
	
	EmitSoundToAll(sSound, iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

bool CelMod_CheckOwner(int iClient, int iEntity)
{
	if (g_bEntity[iEntity] && g_iOwner[iEntity] == iClient)
	{
		return true;
	}
	
	return false;
}

void CelMod_ChooseHudColor(int iClient)
{
	switch (GetRandomInt(0, 6))
	{
		case 0:
		{
			g_iClientColor[iClient][0] = 255;
			g_iClientColor[iClient][1] = 0;
			g_iClientColor[iClient][2] = 0;
			g_iClientColor[iClient][3] = 255;
		}
		case 1:
		{
			g_iClientColor[iClient][0] = 255;
			g_iClientColor[iClient][1] = 128;
			g_iClientColor[iClient][2] = 0;
			g_iClientColor[iClient][3] = 255;
		}
		case 2:
		{
			g_iClientColor[iClient][0] = 255;
			g_iClientColor[iClient][1] = 255;
			g_iClientColor[iClient][2] = 0;
			g_iClientColor[iClient][3] = 255;
		}
		case 3:
		{
			g_iClientColor[iClient][0] = 0;
			g_iClientColor[iClient][1] = 255;
			g_iClientColor[iClient][2] = 0;
			g_iClientColor[iClient][3] = 255;
		}
		case 4:
		{
			g_iClientColor[iClient][0] = 0;
			g_iClientColor[iClient][1] = 0;
			g_iClientColor[iClient][2] = 255;
			g_iClientColor[iClient][3] = 255;
		}
		case 5:
		{
			g_iClientColor[iClient][0] = 255;
			g_iClientColor[iClient][1] = 0;
			g_iClientColor[iClient][2] = 255;
			g_iClientColor[iClient][3] = 255;
		}
		case 6:
		{
			g_iClientColor[iClient][0] = 128;
			g_iClientColor[iClient][1] = 0;
			g_iClientColor[iClient][2] = 255;
			g_iClientColor[iClient][3] = 255;
		}
	}
}

void CelMod_ChooseLandColor(int iClient)
{
	switch (GetRandomInt(0, 6))
	{
		case 0:
		{
			g_iLandColor[iClient][0] = 255;
			g_iLandColor[iClient][1] = 0;
			g_iLandColor[iClient][2] = 0;
			g_iLandColor[iClient][3] = 255;
		}
		case 1:
		{
			g_iLandColor[iClient][0] = 255;
			g_iLandColor[iClient][1] = 128;
			g_iLandColor[iClient][2] = 0;
			g_iLandColor[iClient][3] = 255;
		}
		case 2:
		{
			g_iLandColor[iClient][0] = 255;
			g_iLandColor[iClient][1] = 255;
			g_iLandColor[iClient][2] = 0;
			g_iLandColor[iClient][3] = 255;
		}
		case 3:
		{
			g_iLandColor[iClient][0] = 0;
			g_iLandColor[iClient][1] = 255;
			g_iLandColor[iClient][2] = 0;
			g_iLandColor[iClient][3] = 255;
		}
		case 4:
		{
			g_iLandColor[iClient][0] = 0;
			g_iLandColor[iClient][1] = 0;
			g_iLandColor[iClient][2] = 255;
			g_iLandColor[iClient][3] = 255;
		}
		case 5:
		{
			g_iLandColor[iClient][0] = 255;
			g_iLandColor[iClient][1] = 0;
			g_iLandColor[iClient][2] = 255;
			g_iLandColor[iClient][3] = 255;
		}
		case 6:
		{
			g_iLandColor[iClient][0] = 128;
			g_iLandColor[iClient][1] = 0;
			g_iLandColor[iClient][2] = 255;
			g_iLandColor[iClient][3] = 255;
		}
	}
}

void CelMod_DontOwn(int iClient)
{
	CelMod_ReplyToCommand(iClient, "That doesn't belong to you!");
}

void CelMod_DownloadFiles()
{
	char sBuffer[256];
	Handle hDownloadFiles = OpenFile(g_sDownloads, "r");
	
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

int CelMod_GetEntityColor(int iEntity, int iColor[4])
{
	iColor[0] = g_iColor[iEntity][0], iColor[1] = g_iColor[iEntity][1], iColor[2] = g_iColor[iEntity][2], iColor[3] = g_iColor[iEntity][3];
}

bool CelMod_GetMotion(int iEntity)
{
	return g_bFrozen[iEntity];
}

void CelMod_NotLooking(int iClient)
{
	CelMod_ReplyToCommand(iClient, "You are not looking at anything!");
}

void CelMod_RemoveBeam(int iClient)
{
	char sSound[64];
	float fFinalOrigin[3], fOrigin[3];
	
	GetClientAbsOrigin(iClient, fOrigin);
	
	int iEntity = GetClientAimTarget(iClient, false);
	
	GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fFinalOrigin);
	
	Format(sSound, sizeof(sSound), "ambient/levels/citadel/weapon_disintegrate%i.wav", GetRandomInt(1, 4));
	
	PrecacheSound(sSound);
	
	TE_SetupBeamPoints(fOrigin, fFinalOrigin, g_iLaser, g_iHalo, 0, 15, 0.25, 15.0, 15.0, 1, 0.0, g_iGray, 10);
	TE_SendToAll();
	
	TE_SetupBeamRingPoint(fFinalOrigin, 10.0, 60.0, g_iBeam, g_iHalo, 0, 15, 0.5, 5.0, 0.0, g_iGray, 10, 0);
	TE_SendToAll();
	
	EmitAmbientSound(sSound, fFinalOrigin, iEntity, 100, 0, 1.0, 100, 0.0);
}

void CelMod_RemoveEntity(int iEntity)
{
	DispatchKeyValue(iEntity, "targetname", "cm_entity_removal");
	
	AcceptEntityInput(g_iEntityRemover, "dissolve");
}

void CelMod_SendHudMessage(int iClient, int iChannel, 
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

void CelMod_SetEntityColor(int iEntity, int iR, int iG, int iB, int iA)
{
	SetEntityRenderColor(iEntity, iR, iG, iB, iA);
	SetEntityRenderMode(iEntity, RENDER_TRANSALPHA);
	
	g_iColor[iEntity][0] = iR, g_iColor[iEntity][1] = iG, g_iColor[iEntity][2] = iB, g_iColor[iEntity][3] = iA;
}

void CelMod_SetMotion(int iEntity, bool bFrozen)
{
	g_bFrozen[iEntity] = bFrozen;
	
	if (bFrozen)
	{
		AcceptEntityInput(iEntity, "disablemotion");
	} else {
		AcceptEntityInput(iEntity, "enablemotion");
	}
}

//Plugin Timers:
public Action Timer_DisRemove(Handle hTimer, any iEntity)
{
	CelMod_RemoveEntity(iEntity);
}

public Action Timer_Hud(Handle hTimer)
{
	char sClassname[64], sMessage[256], sName[128], sNickname[128];
	int iColor[4];
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (g_bPlayer[i])
		{
			int iEntity = GetClientAimTarget(i, false);
			
			if (iEntity == -1)
			{
				GetClientName(i, sName, sizeof(sName));
				SAS_GetNickname(i, sNickname, sizeof(sNickname));
				
				CRemoveTags(sNickname, sizeof(sNickname));
				CRemoveTags(sName, sizeof(sName));
				
				Format(sMessage, sizeof(sMessage), "%s | %s | Coins: %i", StrEqual(sNickname, "null") ? sName : sNickname, g_sPlayerTag[i], g_iCoins[i]);
				
				iColor = g_iClientColor[i];
			} else if (g_bEntity[iEntity])
			{
				GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
				
				if (StrContains(sClassname, "cel_") != -1)
				{
					ReplaceString(sClassname, sizeof(sClassname), "cel_", "");
					
					CharToUpper(sClassname[0]);
					
					if (CelMod_CheckOwner(i, iEntity))
					{
						GetClientName(i, sName, sizeof(sName));
						SAS_GetNickname(i, sNickname, sizeof(sNickname));
						
						CRemoveTags(sNickname, sizeof(sNickname));
						CRemoveTags(sName, sizeof(sName));
						
						Format(sMessage, sizeof(sMessage), "%s | %s | Coins: %i\nCel: %s", StrEqual(sNickname, "null") ? sName : sNickname, g_sPlayerTag[i], g_iCoins[i], sClassname);
						
						iColor = g_iClientColor[i];
					} else {
						GetClientName(g_iOwner[iEntity], sName, sizeof(sName));
						SAS_GetNickname(g_iOwner[iEntity], sNickname, sizeof(sNickname));
						
						CRemoveTags(sNickname, sizeof(sNickname));
						CRemoveTags(sName, sizeof(sName));
						
						Format(sMessage, sizeof(sMessage), "Owner: %s\nCel: %s", StrEqual(sNickname, "null") ? sName : sNickname, sClassname);
						
						iColor = g_iClientColor[g_iOwner[iEntity]];
					}
				} else {
					if (CelMod_CheckOwner(i, iEntity))
					{
						GetClientName(i, sName, sizeof(sName));
						SAS_GetNickname(i, sNickname, sizeof(sNickname));
						
						CRemoveTags(sNickname, sizeof(sNickname));
						CRemoveTags(sName, sizeof(sName));
						
						Format(sMessage, sizeof(sMessage), "%s | %s | Coins: %i\nProp: %s", StrEqual(sNickname, "null") ? sName : sNickname, g_sPlayerTag[i], g_iCoins[i], g_sPropname[iEntity]);
						
						iColor = g_iClientColor[i];
					} else {
						GetClientName(g_iOwner[iEntity], sName, sizeof(sName));
						SAS_GetNickname(g_iOwner[iEntity], sNickname, sizeof(sNickname));
						
						CRemoveTags(sNickname, sizeof(sNickname));
						CRemoveTags(sName, sizeof(sName));
						
						Format(sMessage, sizeof(sMessage), "Owner: %s\nProp: %s", StrEqual(sNickname, "null") ? sName : sNickname, g_sPropname[iEntity]);
						
						iColor = g_iClientColor[g_iOwner[iEntity]];
					}
				}
			} else if (g_bPlayer[iEntity])
			{
				GetClientName(iEntity, sName, sizeof(sName));
				SAS_GetNickname(iEntity, sNickname, sizeof(sNickname));
				
				CRemoveTags(sNickname, sizeof(sNickname));
				CRemoveTags(sName, sizeof(sName));
				
				Format(sMessage, sizeof(sMessage), "%s | %s | Coins: %i", StrEqual(sNickname, "null") ? sName : sNickname, g_sPlayerTag[iEntity], g_iCoins[iEntity]);
				
				iColor = g_iClientColor[iEntity];
			} else {
				GetClientName(i, sName, sizeof(sName));
				SAS_GetNickname(i, sNickname, sizeof(sNickname));
				
				CRemoveTags(sNickname, sizeof(sNickname));
				CRemoveTags(sName, sizeof(sName));
				
				Format(sMessage, sizeof(sMessage), "%s | %s | Coins: %i", StrEqual(sNickname, "null") ? sName : sNickname, g_sPlayerTag[i], g_iCoins[i]);
				
				iColor = g_iClientColor[i];
			}
			
			CelMod_SendHudMessage(i, 1, 2.010, -0.110, iColor[0], iColor[1], iColor[2], iColor[3], 0, 0.6, 0.01, 0.01, 0.01, sMessage);
		}
	}
}

//Plugin Events:
public Action Event_Connect(Event eEvent, const char[] sName, bool bDontBroadcast)
{
	if (!bDontBroadcast)
	{
		char sClientName[33], sNetworkID[22], sAddress[32];
		
		eEvent.GetString("name", sClientName, sizeof(sClientName));
		eEvent.GetString("networkid", sNetworkID, sizeof(sNetworkID));
		eEvent.GetString("address", sAddress, sizeof(sAddress));
		
		Event eNewEvent = CreateEvent("player_connect", true);
		eNewEvent.SetString("name", sClientName);
		
		eNewEvent.SetInt("index", GetEventInt(eEvent, "index"));
		eNewEvent.SetInt("userid", GetEventInt(eEvent, "userid"));
		
		eNewEvent.SetString("networkid", sNetworkID);
		eNewEvent.SetString("address", sAddress);
		
		eNewEvent.Fire(true);
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Event_Death(Event eEvent, const char[] sName, bool bDontBroadcast)
{
	char sCName[128], sNameAttacker[128], sNickname[128], sNicknameAttacker[128];
	
	int iAttackerID = eEvent.GetInt("attacker");
	int iClientID = eEvent.GetInt("userid");
	
	int iAttacker = GetClientOfUserId(iAttackerID);
	int iClient = GetClientOfUserId(iClientID);
	
	GetClientName(iAttacker, sNameAttacker, sizeof(sNameAttacker));
	GetClientName(iClient, sCName, sizeof(sCName));
	
	SAS_GetNickname(iAttacker, sNicknameAttacker, sizeof(sNicknameAttacker));
	SAS_GetNickname(iClient, sNickname, sizeof(sNickname));
	
	if (iAttacker == iClient)
		CelMod_PrintToChatAll("{green}%s{default} killed themselves.", StrEqual(sNickname, "null") ? sCName : sNickname);
	else
		CelMod_PrintToChatAll("{green}%s{default} killed {green}%s{default}.", StrEqual(sNicknameAttacker, "null") ? sNameAttacker : sNicknameAttacker, StrEqual(sNickname, "null") ? sCName : sNickname);
	
	int iRagdoll = GetEntPropEnt(iClient, Prop_Send, "m_hRagdoll");
	
	IgniteEntity(iRagdoll, 3.0);
	
	CreateTimer(2.0, Timer_DisRemove, iRagdoll);
}

public Action Event_Disconnect(Event eEvent, const char[] sName, bool bDontBroadcast)
{
	if (!bDontBroadcast)
	{
		char sClientName[33], sNetworkID[22], sReason[65];
		
		eEvent.GetString("name", sClientName, sizeof(sClientName));
		eEvent.GetString("networkid", sNetworkID, sizeof(sNetworkID));
		eEvent.GetString("reason", sReason, sizeof(sReason));
		
		Event eNewEvent = CreateEvent("player_disconnect", true);
		eNewEvent.SetInt("userid", GetEventInt(eEvent, "userid"));
		eNewEvent.SetString("reason", sReason);
		eNewEvent.SetString("name", sClientName);
		eNewEvent.SetString("networkid", sNetworkID);
		
		eNewEvent.Fire(true);
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Event_Spawn(Event eEvent, const char[] sName, bool bDontBroadcast)
{
}

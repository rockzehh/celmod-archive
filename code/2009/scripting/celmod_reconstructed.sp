Handle hNoclipSpeed;
Handle hCheats;
Handle hLightCvar;
Handle hNPCCvar;
Handle hMaxCelsClient;
Handle hMaxPropsClient;
Handle hMaxBreakablesClient;
Handle hMaxNPCsClient;
Handle hMaxVehiclesClient;
Handle hRemoveDisc;
Handle hFakeZom;
Handle hProtectMap;

int iEntDissolve;
int iEntIgnite;

int iRedColor[4] =  { 255, 0, 0, 200 };
int iOrangeColor[4] =  { 255, 128, 0, 200 };
int iYellowColor[4] =  { 255, 255, 0, 200 };
int iGreenColor[4] =  { 0, 255, 0, 200 };
int iBlueColor[4] =  { 0, 0, 255, 200 };
int iWhiteColor[4] =  { 255, 255, 255, 200 };
int iGreyColor[4] =  { 255, 255, 255, 30 };

char toolSound[32];
char npcs[32] = "npc_";
char player[32] = "player";
float EntAng[3];
bool CheatsOn;
int BeamSprite;
int HaloSprite;
int LaserSprite;
int PhysBeam;
int blockMsgs[33];
int lightNum;
int lightCount;
int NPCAllCount;
char propPath[32];
char soundPath[32];
char propErrorPath[32];
char ClientPrefs[32];
int LookingProp[33];
int ViewProp[33];
float SpawnpropTime[33];
float PasteTime[33];
float LightTime[33];
float SoundTime[33];
bool StartCP[33];
char CPClass[33][8];
char CPModel[33][32];
int CPColor[33][4];
int CPRenderFx[33];
int CPRenderMode[33];
int CPFlags[33];
int CPSkin[33];
float CPAngles[33][3];
bool CPFrozen[33];
bool CPBreakable[33];
float grabDist[33][3];
int grabEnt[33];
int grabEntColor[33][4];
MoveType grabEntM[33];
Handle clientGrab[33];
char entSound[3000][64];
char entMusic[3000][64];
float soundTime[3000];
float musicTime[3000];
float copyDist[33][3];
int copyEnt[33];
int copyEntColor[33][4];
bool copyFrozen[33];
MoveType copyMovetype[33];
Handle copyGrab[33];
MoveType oldMove[33];
char undoQue[33][1000][64];
Handle vehicleTimer[33];
int maxPlayersU;
char tempString[64];

#pragma newdecls required

public Plugin myinfo = 
{
	name = "|CelMod|", 
	description = "Various commands used for build/cheat servers.", 
	author = "Celsius", 
	version = "1.3.0.0", 
	url = "www.avmserver.weebly.com"
};
public int OnPluginStart()
{
	RegAdminCmd("v_custom_spawn", Command_ent, 4096, "Creates an entity with specified keyvalues. Pros only.", "", 0);
	RegAdminCmd("v_advisor", Command_advisor, 32, "Creates an advisor.", "", 0);
	RegAdminCmd("v_give", Command_giveOwner, 8, "Gives ownership of an entity to someone.", "", 0);
	RegAdminCmd("v_autobuild", Command_autoStack, 8, "Creates multiple copies of the entity you're looking at in specified frequencies.", "", 0);
	RegConsoleCmd("v_spawn", Command_spawnprop, "Spawns a prop by alias.", 0);
	RegConsoleCmd("v_count", Command_propCount, "Shows your prop count.", 0);
	RegConsoleCmd("v_sound", Command_sound, "Creates a sound emitter.", 0);
	RegConsoleCmd("v_proplist", Command_proplist, "Brings up the list of props.", 0);
	RegConsoleCmd("v_soundlist", Command_soundlist, "Brings up the list of sounds.", 0);
	RegConsoleCmd("v_musiclist", Command_musiclist, "Brings up the list of music.", 0);
	RegConsoleCmd("v_preview", Command_previewprop, "Previews a prop to a player.", 0);
	RegConsoleCmd("+v_forward", Command_vehicleStart, "test", 0);
	RegConsoleCmd("-v_forward", Command_vehicleStop, "test", 0);
	RegConsoleCmd("+v_back", Command_vehicleStartBack, "test", 0);
	RegConsoleCmd("-v_back", Command_vehicleStop, "test", 0);
	RegConsoleCmd("v_copy", Command_copyprop, "Stores a prop in the player's copy queue.", 0);
	RegConsoleCmd("v_paste", Command_pasteprop, "Spawns the prop in the player's copy queue.", 0);
	RegConsoleCmd("v_npc", Command_npccreate, "Creates an npc.", 0);
	RegConsoleCmd("v_ladder", Command_ladder, "Creates a working ladder.", 0);
	RegConsoleCmd("v_showmsgs", Command_msgs, "Decides wether to show ent messages when using commands(v_freeze, v_remove, etc.)", 0);
	RegConsoleCmd("v_remove", Command_remove, "Removes props.", 0);
	RegConsoleCmd("v_undo", Command_undoRemove, "Undo function for use with v_remove.", 0);
	RegConsoleCmd("v_freeze", Command_freeze, "Freezes the entity you're looking at.", 0);
	RegConsoleCmd("v_unfreeze", Command_unfreeze, "Unfreezes the entity you're looking at.", 0);
	RegConsoleCmd("v_skin", Command_skin, "Changes the skin of the entity you're looking at.", 0);
	RegConsoleCmd("v_door", Command_door, "Creates a working door.", 0);
	RegConsoleCmd("v_straight", Command_straighten, "Straightens the prop.", 0);
	RegConsoleCmd("v_setscene", Command_scene, "Sets the choreographed scene for an NPC.", 0);
	RegConsoleCmd("v_relationship", Command_relationship, "Sets the relationship of an NPC.", 0);
	RegConsoleCmd("v_airboat", Command_airboat, "Creates an airboat.", 0);
	RegConsoleCmd("v_gun", Command_airboatgun, "Turns the airboat gun on or off.", 0);
	RegConsoleCmd("v_ignite", Command_ignite, "Ignites the entity for x seconds.", 0);
	RegConsoleCmd("v_jeep", Command_jeep, "Turns an airboat into a jeep.", 0);
	RegConsoleCmd("v_god", Command_god, "Turns invincibility on or off of props.", 0);
	RegConsoleCmd("v_spawnpod", Command_pod, "Creates a pod vehicle out of the prop you're looking at.", 0);
	RegConsoleCmd("v_color", Command_color, "Colors the entity you're looking at.", 0);
	RegConsoleCmd("v_axis", Command_mark, "Creates a marker showing every axis.", 0);
	RegConsoleCmd("v_spawnlight", Command_lightcreate, "Creates a moveable light.", 0);
	RegConsoleCmd("v_solid", Command_solidity, "Turns solidity on the prop on or off.", 0);
	RegConsoleCmd("v_music", Command_music, "Creates a music emitting radio.", 0);
	RegConsoleCmd("v_amt", Command_alpha, "Modifies entity alpha transparency.", 0);
	RegConsoleCmd("v_rotate", Command_rotate, "Rotates an entity. Supports doors.", 0);
	RegConsoleCmd("v_owned", Command_whoowns, "Finds out who owns the picker entity.", 0);
	RegConsoleCmd("+move", Command_startMove, "Makes the entity you're looking at follow you.", 0);
	RegConsoleCmd("-move", Command_stopMove, "Stops moving the entity.", 0);
	RegConsoleCmd("+copy", Command_startCopy, "Copies an entity and makes it follow you.", 0);
	RegConsoleCmd("-copy", Command_stopCopy, "Stops moving copied entity.", 0);
	RegConsoleCmd("say", Command_stopcmd, "Used for the stop command on v_preview.", 0);
	CreateConVar("celmod", "1", "Notification that the server is running celmod(for use with game-monitor,etc.)", 395584, false, 0, false, 0);
	lightCvar = CreateConVar("cm_max_lights", "10", "Maxiumum number of lights allowed on map.", 264512, false, 0, false, 0);
	NPCCvar = CreateConVar("cm_max_npcs", "100", "Maxiumum number of NPCs allowed on map.", 264512, false, 0, false, 0);
	MaxCelsClient = CreateConVar("cm_max_player_cels", "50", "Maxiumum number of CelMod entities a client is allowed.", 264512, false, 0, false, 0);
	MaxNPCsClient = CreateConVar("cm_max_player_npcs", "20", "Maxiumum number of NPCs a client is allowed.", 264512, false, 0, false, 0);
	MaxPropsClient = CreateConVar("cm_max_player_props", "300", "Maxiumum number of props a player is allowed to spawn.", 264512, false, 0, false, 0);
	MaxBreakablesClient = CreateConVar("cm_max_player_breakables", "100", "Maxiumum number of breakable props a player is allowed to spawn.", 264512, false, 0, false, 0);
	MaxVehiclesClient = CreateConVar("cm_max_player_vehicles", "5", "Maxiumum number of vehicles a player is allowed.", 264512, false, 0, false, 0);
	removeDisc = CreateConVar("cm_remove_on_disconnect", "1", "Decides wether to remove the players entities on disconnect.", 264512, false, 0, false, 0);
	fakeZom = CreateConVar("cm_fake_zombies", "1", "Decides wether to spawn fake zombies (used to prevent Windows from crashing)", 264512, false, 0, false, 0);
	protectMap = CreateConVar("cm_protect_map_props", "0", "Map start only. Protects all the map entities from celmod commands.", 264512, false, 0, false, 0);
	CreateConVar("celmod_version", "1.1", "CelMod Version", 395584, false, 0, false, 0);
	cNoclipSpeed = FindConVar("sv_noclipspeed");
	Cheats = FindConVar("sv_cheats");
	BuildPath(PathType0, propPath, 64, "data/celmod/spawns.txt");
	BuildPath(PathType0, soundPath, 64, "data/celmod/sounds.txt");
	BuildPath(PathType0, propErrorPath, 64, "data/celmod/spawnerrors.txt");
	BuildPath(PathType0, ClientPrefs, 64, "data/celmod/clientprefs.txt");
	return 0;
}

int cmMsg(int client, char Msg[])
{
	PrintToChat(client, "\x04|CelMod|\x01 %s", Msg);
	int random = GetRandomInt(0, 1);
	switch (random)
	{
		case 0: {
			ClientCommand(client, "playgamesound NPC_Stalker.FootStepRight");
		}
		case 1: {
			ClientCommand(client, "playgamesound NPC_Stalker.FootStepLeft");
		}
		default: {
		}
	}
	return 0;
}

int PerformByClass(int client, int ent, char action[])
{
	char classname[32];
	char brokeClass[8][32];
	char classMsg[256];
	GetEdictClassname(ent, classname, 32);
	if (StrContains(classname, "_", false) == -1)
	{
		Format(classMsg, 255, "%s %s.", action, classname);
	}
	else
	{
		ExplodeString(classname, "_", brokeClass, 2, 32);
		if (StrEqual(brokeClass[0][brokeClass], "combine", false))
		{
			Format(classMsg, 255, "%s %s %s.", action, brokeClass[0][brokeClass], brokeClass[4]);
		}
		Format(classMsg, 255, "%s %s %s.", action, brokeClass[4], brokeClass[0][brokeClass]);
	}
	cmMsg(client, classMsg);
	return 0;
}

int tooFast(int client)
{
	char fastMsg[256];
	int random = GetRandomInt(0, 3);
	switch (random)
	{
		case 0: {
		}
		case 1: {
		}
		case 2: {
		}
		case 3: {
		}
		default: {
		}
	}
	cmMsg(client, fastMsg);
	return 0;
}

int lookingAt(int client)
{
	if (!blockMsgs[client][0][0])
	{
		cmMsg(client, "You are not looking at anything.");
	}
	return 0;
}

int notYours(int client)
{
	cmMsg(client, "This entity does not belong to you.");
	return 0;
}

int changeBeam(int client, int Ent)
{
	Handle TraceRay;
	int randomSound;
	float COrigin[3];
	float EyeAngles[3];
	float EyeOrigin[3];
	float EndOrigin[3];
	float FinalCOrigin[3];
	GetClientAbsOrigin(client, COrigin);
	FinalCOrigin[0] = COrigin[0];
	FinalCOrigin[4] = COrigin[4];
	FinalCOrigin[8] = COrigin[8] + 32;
	GetClientEyeAngles(client, EyeAngles);
	GetClientEyePosition(client, EyeOrigin);
	TraceRay = TR_TraceRayFilterEx(EyeOrigin, EyeAngles, 1174421507, RayType1, TraceEntityFilter95, any0);
	if (TR_DidHit(TraceRay))
	{
		TR_GetEndPosition(EndOrigin, TraceRay);
		TE_SetupBeamPoints(FinalCOrigin, EndOrigin, PhysBeam, HaloSprite, 0, 15, 0.1, 4, 4, 1, 0, physWhite, 10);
		TE_SendToAll(0);
		TE_SetupSparks(EndOrigin, EntAng, 3, 2);
		TE_SendToAll(0);
		randomSound = GetRandomInt(0, 1);
		switch (randomSound)
		{
			case 0: {
			}
			case 1: {
			}
			default: {
			}
		}
		EmitSoundToAll(toolSound, Ent, 2, 100, 0, 1, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0);
	}
	CloseHandle(TraceRay);
	return 0;
}

int ReadQue(int client)
{
	int I = 0;
	while (I < 1000)
	{
		if (StrEqual(undoQue[client][0][0][I], "", false))
		{
			return I;
		}
		I++;
	}
	return -1;
}

int WriteQue(int client, int ent, int num)
{
	char queString[72][256];
	int eColor[4];
	float angRot[3];
	float entOrgn[3];
	int renderFx;
	int skinNum;
	int entFlags;
	int takedamage;
	int solid;
	int coloroffset;
	GetEdictClassname(ent, queString[0][queString], 32);
	GetEntPropString(ent, PropType1, "m_ModelName", queString[4], 128);
	GetEntPropString(ent, PropType1, "m_iGlobalname", queString[68], 128);
	skinNum = GetEntProp(ent, PropType1, "m_nSkin", 1);
	solid = GetEntProp(ent, PropType0, "m_nSolidType", 1);
	IntToString(skinNum, queString[8], 16);
	IntToString(solid, queString[12], 16);
	coloroffset = GetEntSendPropOffs(ent, "m_clrRender", false);
	eColor[0] = GetEntData(ent, coloroffset, 1);
	eColor[4] = GetEntData(ent, coloroffset + 1, 1);
	eColor[8] = GetEntData(ent, coloroffset + 2, 1);
	eColor[12] = GetEntData(ent, coloroffset + 3, 1);
	renderFx = GetEntProp(ent, PropType0, "m_nRenderFX", 1);
	GetEntPropVector(ent, PropType1, "m_vecAbsOrigin", entOrgn);
	GetEntPropVector(ent, PropType1, "m_angRotation", angRot);
	entFlags = GetEntProp(ent, PropType1, "m_spawnflags", 1);
	takedamage = GetEntProp(ent, PropType1, "m_takedamage", 1);
	IntToString(renderFx, queString[16], 16);
	IntToString(entFlags, queString[20], 16);
	IntToString(eColor[0], queString[24], 16);
	IntToString(eColor[4], queString[28], 16);
	IntToString(eColor[8], queString[32], 16);
	IntToString(eColor[12], queString[36], 16);
	IntToString(takedamage, queString[40], 16);
	IntToString(RoundFloat(entOrgn[0]), queString[44], 16);
	IntToString(RoundFloat(entOrgn[4]), queString[48], 16);
	IntToString(RoundFloat(entOrgn[8]), queString[52], 16);
	IntToString(RoundFloat(angRot[0]), queString[56], 16);
	IntToString(RoundFloat(angRot[4]), queString[60], 16);
	IntToString(RoundFloat(angRot[8]), queString[64], 16);
	ImplodeStrings(queString, 18, "*", undoQue[client][0][0][num], 255);
	return 0;
}

int LoadString(Handle anyHandle, char Key[32], char SaveKey[256], char DefaultValue[256], char Reference[256])
{
	KvJumpToKey(anyHandle, Key, false);
	KvGetString(anyHandle, SaveKey, Reference, 255, DefaultValue);
	KvRewind(anyHandle);
	return 0;
}

int SaveString(Handle anyHandle, char Key[32], char SaveKey[256], char Variable[256])
{
	KvJumpToKey(anyHandle, Key, true);
	KvSetString(anyHandle, SaveKey, Variable);
	KvRewind(anyHandle);
	return 0;
}

int DebugError(char propAlias[256], char modelDir[128])
{
	Handle PropsE = CreateKeyValues("Props", "", "");
	FileToKeyValues(PropsE, propErrorPath);
	SaveString(PropsE, "Errors", propAlias, "Model does not match up with prop type.");
	KeyValuesToFile(PropsE, propErrorPath);
	CloseHandle(PropsE);
	return 0;
}

int FindOwner(int client, int Ent)
{
	if (IsValidEntity(Ent))
	{
		char clientEnt[32];
		char entGlobal[64];
		IntToString(client, clientEnt, 32);
		GetEntPropString(Ent, PropType1, "m_iGlobalname", entGlobal, 64);
		if (StrEqual(clientEnt, entGlobal, false))
		{
			return 1;
		}
		if (StrEqual(entGlobal, "", false))
		{
			return 0;
		}
		return -1;
	}
	return -1;
}

int SetOwner(int client, int Ent)
{
	char clientEnt[32];
	IntToString(client, clientEnt, 32);
	DispatchKeyValue(Ent, "globalname", clientEnt);
	return 0;
}

int CountNPCs(int client)
{
	int NPCCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE))
		{
			char pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			if (StrContains(pClass, "npc_", false))
			{
				AllE++;
			}
			else
			{
				NPCCount += 1;
				AllE++;
			}
			AllE++;
		}
		AllE++;
	}
	return NPCCount;
}

int CountProps(int client)
{
	int PropCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE))
		{
			char pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			int var2;
			if (StrContains(pClass, "prop_", false) != -1)
			{
				PropCount += 1;
				AllE++;
			}
			AllE++;
		}
		AllE++;
	}
	return PropCount;
}

int CountCels(int client)
{
	int CelCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE))
		{
			char pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			if (StrContains(pClass, "cel_", false))
			{
				AllE++;
			}
			else
			{
				CelCount += 1;
				AllE++;
			}
			AllE++;
		}
		AllE++;
	}
	return CelCount;
}

int CountBreakables(int client)
{
	int BreakableCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE))
		{
			char pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			int var2;
			if (StrEqual(pClass, "prop_physics_breakable", false))
			{
				BreakableCount += 1;
				AllE++;
			}
			AllE++;
		}
		AllE++;
	}
	return BreakableCount;
}

int CountVehicles(int client)
{
	int VehicleCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE))
		{
			char pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			int var2;
			if (StrEqual(pClass, "prop_vehicle_airboat", false))
			{
				VehicleCount += 1;
				AllE++;
			}
			AllE++;
		}
		AllE++;
	}
	return VehicleCount;
}

int CountLights()
{
	lightCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		if (IsValidEntity(AllE))
		{
			char cClass[32];
			GetEdictClassname(AllE, cClass, 32);
			if (StrEqual(cClass, "cel_light", false))
			{
				lightCount = lightCount + 1;
				AllE++;
			}
			AllE++;
		}
		AllE++;
	}
	return lightCount;
}

int CountAllNPCs()
{
	NPCAllCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		if (IsValidEntity(AllE))
		{
			char gName[256];
			GetEntPropString(AllE, PropType1, "m_iGlobalname", gName, 255);
			if (!StrEqual(gName, "", false))
			{
				char cClass[32];
				GetEdictClassname(AllE, cClass, 32);
				int var1;
				if (StrContains(cClass, npcs, false))
				{
					NPCAllCount = NPCAllCount + 1;
					AllE++;
				}
				AllE++;
			}
			AllE++;
		}
		AllE++;
	}
	return NPCAllCount;
}

int resetCvars(int client)
{
	LookingProp[client] = 0;
	ViewProp[client] = -1;
	StartCP[client] = 0;
	SpawnpropTime[client] = 0;
	PasteTime[client] = 0;
	LightTime[client] = 0;
	SoundTime[client] = 0;
	clientGrab[client] = 0;
	copyGrab[client] = 0;
	vehicleTimer[client] = 0;
	int I = 0;
	while (I < 1000)
	{
		I++;
	}
	return 0;
}

public int OnMapStart()
{
	lightNum = 1;
	lightCount = 0;
	NPCAllCount = 0;
	SetConVarInt(cNoclipSpeed, 3, true, false);
	ServerCommand("exec skill.cfg");
	PrecacheModel("models/advisor.mdl", false);
	PrecacheModel("models/airboat.mdl", false);
	PrecacheModel("models/buggy.mdl", false);
	PrecacheModel("models/zombie/classic.mdl", false);
	PrecacheModel("models/zombie/poison.mdl", false);
	PrecacheModel("models/zombie/fast.mdl", false);
	PrecacheModel("models/roller_spikes.mdl", false);
	PrecacheModel("models/props_junk/popcan01a.mdl", false);
	PrecacheModel("models/props_lab/citizenradio.mdl", false);
	BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", false);
	HaloSprite = PrecacheModel("materials/sprites/halo01.vmt", false);
	LaserSprite = PrecacheModel("materials/sprites/laser.vmt", false);
	PhysBeam = PrecacheModel("materials/sprites/physbeam.vmt", false);
	PrecacheSound("ambient/levels/citadel/weapon_disintegrate1.wav", false);
	PrecacheSound("ambient/levels/citadel/weapon_disintegrate2.wav", false);
	PrecacheSound("ambient/levels/citadel/weapon_disintegrate3.wav", false);
	PrecacheSound("ambient/levels/citadel/weapon_disintegrate4.wav", false);
	PrecacheSound("weapons/airboat/airboat_gun_lastshot1.wav", false);
	PrecacheSound("weapons/airboat/airboat_gun_lastshot2.wav", false);
	PrecacheSound("npc/scanner/scanner_talk1.wav", false);
	PrecacheSound("weapons/mortar/mortar_fire1.wav", false);
	PrecacheSound("npc/turret_floor/ping.wav", false);
	PrecacheSound("npc/roller/mine/rmine_explode_shock1.wav", false);
	EntDissolve = CreateEntityByName("env_entity_dissolver", -1);
	DispatchKeyValue(EntDissolve, "target", "deleted");
	DispatchKeyValue(EntDissolve, "magnitude", "50");
	DispatchKeyValue(EntDissolve, "dissolvetype", "3");
	DispatchSpawn(EntDissolve);
	DispatchKeyValue(EntDissolve, "classname", "cel_entity_dissolver");
	int metro = CreateEntityByName("npc_metropolice", -1);
	DispatchSpawn(metro);
	CreateTimer(0.2, RemoveCop, metro, 0);
	EntIgnite = CreateEntityByName("env_entity_igniter", -1);
	DispatchKeyValue(EntIgnite, "target", "ignited");
	DispatchSpawn(EntIgnite);
	DispatchKeyValue(EntIgnite, "classname", "cel_entity_igniter");
	if (GetConVarBool(protectMap))
	{
		int MaxEnts;
		int E;
		MaxEnts = GetMaxEntities();
		E = 1;
		while (E <= MaxEnts)
		{
			DispatchKeyValue(E, "globalname", "-2");
			E++;
		}
	}
	maxPlayersU = GetMaxClients();
	return 0;
}

public int OnPluginEnd()
{
	RemoveEdict(EntDissolve);
	RemoveEdict(EntIgnite);
	return 0;
}

public bool FilterPlayer(int entity, int contentsMask)
{
	return entity > maxPlayersU;
}

public int useSound(char output[], int caller, int activator, float delay)
{
	if (soundTime[activator][0][0] < GetGameTime() - 1)
	{
		char entClass[32];
		GetEdictClassname(activator, entClass, 32);
		if (StrEqual(entClass, "cel_sound", false))
		{
			EmitSoundToAll(entSound[activator][0][0], activator, 0, 75, 0, 1, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0);
			soundTime[activator] = GetGameTime();
		}
	}
	return 0;
}

public int useMusic(char output[], int caller, int activator, float delay)
{
	char mBreak[16][128];
	ExplodeString(entMusic[activator][0][0], "|", mBreak, 4, 128);
	if (musicTime[activator][0][0] < GetGameTime() - StringToInt(mBreak[4], 10))
	{
		char entClass[32];
		GetEdictClassname(activator, entClass, 32);
		if (StrEqual(entClass, "cel_music", false))
		{
			EmitSoundToAll(mBreak[0][mBreak], activator, 0, StringToInt(mBreak[8], 10), 0, 1, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0);
			musicTime[activator] = GetGameTime();
			if (StringToInt(mBreak[12], 10) == 1)
			{
				CreateTimer(StringToFloat(mBreak[4]), replaySound, activator, 0);
			}
		}
	}
	else
	{
		StopSound(activator, 0, mBreak[0][mBreak]);
		musicTime[activator] = 0;
	}
	return 0;
}

public Action replaySound(Handle timer, any activator)
{
	AcceptEntityInput(activator, "Use", -1, -1, 0);
	char mBreak[16][128];
	ExplodeString(entMusic[activator][0][0], "|", mBreak, 4, 128);
	CreateTimer(StringToFloat(mBreak[4]), replaySound, activator, 0);
	return Action0;
}

public int OnClientPutInServer(int client)
{
	resetCvars(client);
	return 0;
}

public int OnClientDisconnect(int client)
{
	resetCvars(client);
	int Me;
	int E;
	Me = GetMaxEntities();
	if (GetConVarBool(removeDisc))
	{
		E = 1;
		while (E < Me)
		{
			if (IsValidEntity(E))
			{
				if (FindOwner(client, E) == 1)
				{
					char pClass[32];
					GetEdictClassname(E, pClass, 32);
					if (StrContains(pClass, "prop_vehicle", false))
					{
						if (StrEqual(pClass, "cel_light", false))
						{
							AcceptEntityInput(GetEntPropEnt(E, PropType1, "m_hMoveChild"), "turnoff", -1, -1, 0);
						}
						if (StrEqual(pClass, "cel_music", false))
						{
							char mBreak[12][128];
							ExplodeString(entMusic[E][0][0], "|", mBreak, 3, 128);
							StopSound(E, 0, mBreak[0][mBreak]);
						}
					}
					else
					{
						if (GetEntPropEnt(E, PropType1, "m_hPlayer") != -1)
						{
							AcceptEntityInput(E, "exitvehicle", -1, -1, 0);
						}
					}
					CreateTimer(0.1, delayRemove, E, 0);
					E++;
				}
				E++;
			}
			E++;
		}
	}
	else
	{
		E = 1;
		while (E < Me)
		{
			if (IsValidEntity(E))
			{
				if (FindOwner(client, E) == 1)
				{
					char ownBuffers[8][32];
					char ownerName[64];
					GetClientName(client, ownBuffers[4], 32);
					GetClientAuthString(client, ownBuffers[0][ownBuffers], 32);
					ImplodeStrings(ownBuffers, 2, "*", ownerName, 64);
					DispatchKeyValue(E, "globalname", ownerName);
					E++;
				}
				E++;
			}
			E++;
		}
	}
	return 0;
}

public Action delayRemove(Handle timer, any E)
{
	AcceptEntityInput(E, "Kill", -1, -1, 0);
	return Action0;
}

public Action RemoveCop(Handle timer, any metro)
{
	AcceptEntityInput(metro, "Kill", -1, -1, 0);
	return Action0;
}

public Action Command_spawnprop(int client, int Args)
{
	if (Args < 1)
	{
		ReplyToCommand(client, "Usage: v_spawn <prop alias> <extra options>");
		ReplyToCommand(client, "Type 'v_proplist' or say 'celprops' for a list of prop aliases.");
		return Action3;
	}
	if (SpawnpropTime[client][0][0] <= GetGameTime() - 1)
	{
		char propAlias[256];
		char propBool[32];
		GetCmdArg(1, propAlias, 255);
		GetCmdArg(2, propBool, 32);
		Handle Props;
		char PropString[256];
		char KeyType[32];
		Props = CreateKeyValues("Props", "", "");
		FileToKeyValues(Props, propPath);
		LoadString(Props, KeyType, propAlias, "Null", PropString);
		if (!StrContains(PropString, "Null", false))
		{
			cmMsg(client, "Prop not found.");
			return Action3;
		}
		int propEnt;
		char propBuffer[8][128];
		ExplodeString(PropString, "^", propBuffer, 2, 128);
		if (StrEqual(propBuffer[0][propBuffer], "2", false))
		{
			if (GetConVarInt(MaxPropsClient) <= CountProps(client))
			{
				Format(tempString, 255, "You've reached your max prop count(%d).", GetConVarInt(MaxPropsClient));
				cmMsg(client, tempString);
				return Action3;
			}
			propEnt = CreateEntityByName("prop_physics", -1);
		}
		else
		{
			if (StrEqual(propBuffer[0][propBuffer], "1", false))
			{
				if (GetConVarInt(MaxPropsClient) <= CountProps(client))
				{
					Format(tempString, 255, "You've reached your max prop count(%d).", GetConVarInt(MaxPropsClient));
					cmMsg(client, tempString);
					return Action3;
				}
				propEnt = CreateEntityByName("prop_physics_multiplayer", -1);
			}
			if (StrEqual(propBuffer[0][propBuffer], "3", false))
			{
				if (GetConVarInt(MaxCelsClient) <= CountCels(client))
				{
					Format(tempString, 255, "You've reached your max cel count(%d).", GetConVarInt(MaxCelsClient));
					cmMsg(client, tempString);
					return Action3;
				}
				propEnt = CreateEntityByName("cycler", -1);
			}
		}
		DispatchKeyValue(propEnt, "model", propBuffer[4]);
		DispatchKeyValue(propEnt, "physdamagescale", "1.0");
		if (!StrEqual(propBuffer[0][propBuffer], "3", false))
		{
			if (StrEqual(propBool, "frozen", false))
			{
				DispatchKeyValue(propEnt, "spawnflags", "264");
			}
			DispatchKeyValue(propEnt, "spawnflags", "256");
		}
		if (!DispatchSpawn(propEnt))
		{
			DebugError(propAlias, propBuffer[4]);
			cmMsg(client, "Unable to spawn prop. Error detected.");
			return Action3;
		}
		DispatchSpawn(propEnt);
		if (!StrEqual(propBuffer[0][propBuffer], "3", false))
		{
			if (GetEntProp(propEnt, PropType1, "m_takedamage", 4) == 2)
			{
				if (GetConVarInt(MaxBreakablesClient) <= CountBreakables(client))
				{
					Format(tempString, 255, "You've reached your max breakable prop count(%d).", GetConVarInt(MaxBreakablesClient));
					cmMsg(client, tempString);
					return Action3;
				}
				if (StrEqual(propBuffer[0][propBuffer], "2", false))
				{
					DispatchKeyValue(propEnt, "classname", "prop_physics_breakable");
				}
				DispatchKeyValue(propEnt, "classname", "prop_physics_m_breakable");
			}
			if (StrEqual(propBool, "god", false))
			{
				if (GetEntProp(propEnt, PropType1, "m_takedamage", 4) == 2)
				{
					SetEntProp(propEnt, PropType1, "m_takedamage", any0, 1);
				}
			}
		}
		else
		{
			DispatchKeyValue(propEnt, "classname", "cel_doll");
		}
		float SpawnOrigin[3];
		float SpawnAngles[3];
		float COrigin[3];
		float CEyeAngles[3];
		GetClientEyeAngles(client, CEyeAngles);
		GetClientAbsOrigin(client, COrigin);
		SpawnOrigin[0] = FloatAdd(COrigin[0], Cosine(DegToRad(CEyeAngles[4])) * 50);
		SpawnOrigin[4] = FloatAdd(COrigin[4], Sine(DegToRad(CEyeAngles[4])) * 50);
		if (StrEqual(propBuffer[0][propBuffer], "3", false))
		{
			SpawnOrigin[8] = COrigin[8];
		}
		else
		{
			SpawnOrigin[8] = COrigin[8] + 40;
		}
		SpawnAngles[4] = CEyeAngles[4] + 180;
		TeleportEntity(propEnt, SpawnOrigin, SpawnAngles, NULL_VECTOR);
		SetOwner(client, propEnt);
		SpawnpropTime[client] = GetGameTime();
		CloseHandle(Props);
	}
	else
	{
		tooFast(client);
		int var1 = SpawnpropTime[client];
		var1 = var1[0][0] + 1;
	}
	SetCmdReplySource(ReplySource0);
	return Action3;
}

public Action Command_proplist(int client, int Args)
{
	FakeClientCommand(client, "say celprops");
	PrintToConsole(client, "Displaying prop list... Exit console to view.");
	return Action3;
}

public Action Command_soundlist(int client, int Args)
{
	FakeClientCommand(client, "say celsounds");
	PrintToConsole(client, "Displaying sound list... Exit console to view.");
	return Action3;
}

public Action Command_musiclist(int client, int Args)
{
	FakeClientCommand(client, "say celmusic");
	PrintToConsole(client, "Displaying music list... Exit console to view.");
	return Action3;
}

public Action Command_previewprop(int client, int Args)
{
	if (Args < 1)
	{
		PrintToConsole(client, "Usage: v_preview <prop alias>");
		PrintToConsole(client, "Type 'v_proplist' for a list of prop aliases.");
		return Action3;
	}
	if (LookingProp[client][0][0])
	{
		if (LookingProp[client][0][0] == 1)
		{
			cmMsg(client, "You are already viewing a prop.");
			cmMsg(client, "Type \"stop\" in chat to stop viewing.");
		}
		return Action3;
	}
	char propAlias[256];
	char propBool[32];
	GetCmdArg(1, propAlias, 255);
	GetCmdArg(2, propBool, 32);
	Handle Props;
	char PropString[256];
	char KeyType[32];
	Props = CreateKeyValues("Props", "", "");
	FileToKeyValues(Props, propPath);
	LoadString(Props, KeyType, propAlias, "Null", PropString);
	if (!StrContains(PropString, "Null", false))
	{
		cmMsg(client, "Prop not found.");
		return Action3;
	}
	int propEnt;
	char propBuffer[8][128];
	ExplodeString(PropString, "^", propBuffer, 2, 128);
	int var1;
	if (StrEqual(propBuffer[0][propBuffer], "1", false))
	{
		propEnt = CreateEntityByName("prop_physics_multiplayer", -1);
	}
	else
	{
		if (StrEqual(propBuffer[0][propBuffer], "2", false))
		{
			propEnt = CreateEntityByName("prop_physics", -1);
		}
		if (StrEqual(propBuffer[0][propBuffer], "3", false))
		{
			propEnt = CreateEntityByName("cycler", -1);
		}
	}
	DispatchKeyValue(propEnt, "model", propBuffer[4]);
	DispatchKeyValue(propEnt, "rendermode", "1");
	DispatchKeyValue(propEnt, "renderamt", "128");
	DispatchKeyValue(propEnt, "renderfx", "16");
	DispatchKeyValue(propEnt, "spawnflags", "512");
	if (!DispatchSpawn(propEnt))
	{
		cmMsg(client, "Unable to preview prop. Error detected.");
		return Action3;
	}
	DispatchSpawn(propEnt);
	SetEntPropEnt(propEnt, PropType1, "m_hMoveParent", client);
	SetEntProp(propEnt, PropType0, "m_nSolidType", any0, 4);
	SetEntProp(propEnt, PropType1, "m_takedamage", any0, 4);
	SetEntityMoveType(propEnt, MoveType0);
	DispatchKeyValue(propEnt, "classname", "func_preview");
	float SpawnOrigin[3];
	float SpawnAngles[3];
	float COrigin[3];
	float CEyeAngles[3];
	GetClientEyeAngles(client, CEyeAngles);
	GetClientAbsOrigin(client, COrigin);
	SpawnOrigin[0] = FloatAdd(COrigin[0], Cosine(DegToRad(CEyeAngles[4])) * 60);
	SpawnOrigin[4] = FloatAdd(COrigin[4], Sine(DegToRad(CEyeAngles[4])) * 60);
	if (StrEqual(propBuffer[0][propBuffer], "3", false))
	{
		SpawnOrigin[8] = COrigin[8];
	}
	else
	{
		SpawnOrigin[8] = COrigin[8] + 35;
	}
	SpawnAngles[4] = CEyeAngles[4] + 180;
	DispatchKeyValueVector(propEnt, "origin", SpawnOrigin);
	DispatchKeyValueVector(propEnt, "angles", SpawnAngles);
	SetOwner(client, propEnt);
	LookingProp[client] = 1;
	ViewProp[client] = propEnt;
	Format(tempString, 255, "You are now viewing %s.", propAlias);
	cmMsg(client, tempString);
	cmMsg(client, "Type \"stop\" in chat to stop viewing.");
	return Action3;
}

public Action Command_stopcmd(int client, int Args)
{
	char check[192];
	GetCmdArg(1, check, 192);
	int var1;
	if (StrEqual(check, "stop", false))
	{
		LookingProp[client] = 0;
		RemoveEdict(ViewProp[client][0][0]);
		return Action3;
	}
	return Action0;
}

public Action Command_copyprop(int client, int Args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int cpEnt;
	char cpClass[32];
	cpEnt = GetClientAimTarget(client, false);
	GetEdictClassname(cpEnt, cpClass, 32);
	if (!StrContains(cpClass, "prop_physics", false))
	{
		GetEdictClassname(cpEnt, CPClass[client][0][0], 32);
		GetEntPropString(cpEnt, PropType1, "m_ModelName", CPModel[client][0][0], 128);
		int coloroffset = GetEntSendPropOffs(cpEnt, "m_clrRender", false);
		CPColor[client][0][0][0] = GetEntData(cpEnt, coloroffset, 1);
		CPColor[client][0][0][4] = GetEntData(cpEnt, coloroffset + 1, 1);
		CPColor[client][0][0][8] = GetEntData(cpEnt, coloroffset + 2, 1);
		CPColor[client][0][0][12] = GetEntData(cpEnt, coloroffset + 3, 1);
		CPRenderFx[client] = GetEntProp(cpEnt, PropType0, "m_nRenderFX", 1);
		CPRenderMode[client] = GetEntProp(cpEnt, PropType0, "m_nRenderMode", 1);
		GetEntPropVector(cpEnt, PropType1, "m_angRotation", CPAngles[client][0][0]);
		CPSkin[client] = GetEntProp(cpEnt, PropType1, "m_nSkin", 1);
		CPFlags[client] = GetEntProp(cpEnt, PropType1, "m_spawnflags", 1);
		if (GetEntityMoveType(cpEnt))
		{
			CPFrozen[client] = 0;
		}
		else
		{
			CPFrozen[client] = 1;
		}
		if (GetEntProp(cpEnt, PropType1, "m_takedamage", 4) == 2)
		{
			CPBreakable[client] = 1;
		}
		else
		{
			CPBreakable[client] = 0;
		}
		StartCP[client] = 1;
		if (blockMsgs[client][0][0])
		{
		}
		else
		{
			cmMsg(client, "Set physics prop to copy queue.");
		}
	}
	else
	{
		cmMsg(client, "You cannot copy this entity.");
	}
	return Action3;
}

public Action Command_pasteprop(int client, int Args)
{
	if (!StartCP[client][0][0])
	{
		cmMsg(client, "No prop found in copy queue.");
		return Action3;
	}
	if (PasteTime[client][0][0] <= GetGameTime() - 1)
	{
		int cpEnt;
		char cpFlags[32];
		char cpRenderFx[32];
		char cpRenderMode[32];
		char cpSkin[32];
		IntToString(CPFlags[client][0][0], cpFlags, 32);
		IntToString(CPRenderFx[client][0][0], cpRenderFx, 32);
		IntToString(CPRenderMode[client][0][0], cpRenderMode, 32);
		IntToString(CPSkin[client][0][0], cpSkin, 32);
		if (StrEqual(CPClass[client][0][0], "prop_physics_breakable", false))
		{
			cpEnt = CreateEntityByName("prop_physics", -1);
		}
		else
		{
			if (StrEqual(CPClass[client][0][0], "prop_physics_m_breakable", false))
			{
				cpEnt = CreateEntityByName("prop_physics_multiplayer", -1);
			}
			cpEnt = CreateEntityByName(CPClass[client][0][0], -1);
		}
		if (GetConVarInt(MaxPropsClient) <= CountProps(client))
		{
			Format(tempString, 255, "You've reached your max prop count(%d).", GetConVarInt(MaxPropsClient));
			cmMsg(client, tempString);
			AcceptEntityInput(cpEnt, "Kill", -1, -1, 0);
			return Action3;
		}
		DispatchKeyValue(cpEnt, "model", CPModel[client][0][0]);
		DispatchKeyValue(cpEnt, "skin", cpSkin);
		DispatchKeyValue(cpEnt, "renderfx", cpRenderFx);
		DispatchKeyValue(cpEnt, "rendermode", cpRenderMode);
		DispatchKeyValue(cpEnt, "spawnflags", cpFlags);
		if (!DispatchSpawn(cpEnt))
		{
			AcceptEntityInput(cpEnt, "Kill", -1, -1, 0);
			if (StrEqual(CPClass[client][0][0], "prop_physics", false))
			{
				cpEnt = CreateEntityByName("prop_physics_override", -1);
				DispatchKeyValue(cpEnt, "model", CPModel[client][0][0]);
				DispatchKeyValue(cpEnt, "skin", cpSkin);
				DispatchKeyValue(cpEnt, "renderfx", cpRenderFx);
				DispatchKeyValue(cpEnt, "rendermode", cpSkin);
				DispatchKeyValue(cpEnt, "spawnflags", cpFlags);
			}
			cmMsg(client, "Error pasting prop.");
			return Action3;
		}
		DispatchSpawn(cpEnt);
		SetEntityRenderColor(cpEnt, CPColor[client][0][0][0], CPColor[client][0][0][4], CPColor[client][0][0][8], CPColor[client][0][0][12]);
		if (GetEntProp(cpEnt, PropType1, "m_takedamage", 4) == 2)
		{
			if (GetConVarInt(MaxBreakablesClient) <= CountBreakables(client))
			{
				Format(tempString, 255, "You've reached your max breakable prop count(%d).", GetConVarInt(MaxBreakablesClient));
				cmMsg(client, tempString);
				AcceptEntityInput(cpEnt, "Kill", -1, -1, 0);
				return Action3;
			}
			char cpClass[32];
			GetEdictClassname(cpEnt, cpClass, 32);
			if (StrEqual(cpClass, "prop_physics", false))
			{
				DispatchKeyValue(cpEnt, "classname", "prop_physics_breakable");
			}
			else
			{
				DispatchKeyValue(cpEnt, "classname", "prop_physics_m_breakable");
			}
		}
		if (CPBreakable[client][0][0])
		{
			SetEntProp(cpEnt, PropType1, "m_takedamage", any2, 1);
		}
		else
		{
			SetEntProp(cpEnt, PropType1, "m_takedamage", any0, 1);
		}
		if (CPFrozen[client][0][0])
		{
			SetEntityMoveType(cpEnt, MoveType0);
			AcceptEntityInput(cpEnt, "disablemotion", -1, -1, 0);
		}
		Handle TraceRay;
		float EyeAngles[3];
		float EyeOrigin[3];
		float LookOrigin[3];
		GetClientEyeAngles(client, EyeAngles);
		GetClientEyePosition(client, EyeOrigin);
		TraceRay = TR_TraceRayFilterEx(EyeOrigin, EyeAngles, 1174421507, RayType1, TraceEntityFilter95, any0);
		if (TR_DidHit(TraceRay))
		{
			TR_GetEndPosition(LookOrigin, TraceRay);
			TeleportEntity(cpEnt, LookOrigin, CPAngles[client][0][0], NULL_VECTOR);
			SetOwner(client, cpEnt);
			changeBeam(client, cpEnt);
			PasteTime[client] = GetGameTime();
			if (!blockMsgs[client][0][0])
			{
				cmMsg(client, "Pasted physics prop.");
			}
			CloseHandle(TraceRay);
		}
	}
	else
	{
		tooFast(client);
		int var1 = PasteTime[client];
		var1 = var1[0][0] + 1;
	}
	return Action3;
}

public Action Command_msgs(int client, int Args)
{
	if (Args < 1)
	{
		PrintToConsole(client, "\"v_showmsgs\" = \"%d\", blockMsgs[client]");
		PrintToConsole(client, " - Decides wether to show unnecessary messages when using CelMod commands.");
		return Action3;
	}
	Handle CPrefs = CreateKeyValues("ClientPreferences", "", "");
	FileToKeyValues(CPrefs, ClientPrefs);
	char steamID[256];
	char toggle[4];
	GetCmdArg(1, toggle, 2);
	if (StrEqual(toggle, "1", false))
	{
		if (blockMsgs[client][0][0] == 1)
		{
			GetClientAuthString(client, steamID, 255);
			blockMsgs[client] = 0;
			SaveString(CPrefs, "BlockMsgs", steamID, "0");
			cmMsg(client, "Messages will now be shown.");
		}
		else
		{
			cmMsg(client, "Messages are already shown.");
		}
		return Action3;
	}
	if (StrEqual(toggle, "0", false))
	{
		if (blockMsgs[client][0][0])
		{
			cmMsg(client, "Messages are already blocked.");
		}
		else
		{
			GetClientAuthString(client, steamID, 255);
			blockMsgs[client] = 1;
			SaveString(CPrefs, "BlockMsgs", steamID, "1");
			cmMsg(client, "Messages will now be blocked.");
		}
		return Action3;
	}
	KeyValuesToFile(CPrefs, ClientPrefs);
	CloseHandle(CPrefs);
	return Action3;
}

public Action Command_advisor(int client, int Args)
{
	int advisor = CreateEntityByName("npc_clawscanner", -1);
	DispatchSpawn(advisor);
	SetEntityModel(advisor, "models/advisor.mdl");
	float COrigin[3];
	float AOrigin[3];
	GetClientAbsOrigin(client, COrigin);
	AOrigin[0] = COrigin[0];
	AOrigin[4] = COrigin[4];
	AOrigin[8] = COrigin[8] + 100;
	TeleportEntity(advisor, AOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntProp(advisor, PropType1, "m_takedamage", any0, 1);
	SetVariantString("player d_ht");
	AcceptEntityInput(advisor, "setrelationship", -1, -1, 0);
	DispatchKeyValue(advisor, "classname", "npc_advisor");
	DispatchKeyValue(advisor, "OnFoundPlayer", "!caller,equipmine,,0,-1");
	DispatchKeyValue(advisor, "OnFoundPlayer", "!caller,deploymine,,5,-1");
	DispatchKeyValue(advisor, "globalname", "-2");
	return Action3;
}

public Action Command_npccreate(int client, int Args)
{
	if (Args < 1)
	{
		PrintToConsole(client, "Usage: v_npc <npc name>");
		PrintToConsole(client, "NPC name shouldn't have 'npc_' before it.");
		return Action3;
	}
	if (GetConVarInt(NPCCvar) > CountAllNPCs())
	{
		if (GetConVarInt(MaxNPCsClient) > CountNPCs(client))
		{
			char npcA[32];
			char npcBuffer[8][64];
			char npcClass[64];
			GetCmdArg(1, npcA, 32);
			ImplodeStrings(npcBuffer, 2, "_", npcClass, 64);
			int NPC;
			bool fastZombie = 0;
			if (GetConVarBool(fakeZom))
			{
				if (StrEqual(npcA, "zombie", false))
				{
					NPC = CreateEntityByName("npc_combine_s", -1);
					DispatchKeyValue(NPC, "model", "models/zombie/classic.mdl");
					DispatchKeyValue(NPC, "setbodygroup", "1");
				}
				if (StrEqual(npcA, "fastzombie", false))
				{
					NPC = CreateEntityByName("npc_combine_s", -1);
					DispatchKeyValue(NPC, "model", "models/zombie/fast.mdl");
					DispatchKeyValue(NPC, "setbodygroup", "1");
				}
				if (StrEqual(npcA, "poisonzombie", false))
				{
					NPC = CreateEntityByName("npc_combine_s", -1);
					DispatchKeyValue(NPC, "model", "models/zombie/poison.mdl");
					DispatchKeyValue(NPC, "setbodygroup", "7");
				}
			}
			else
			{
				if (StrEqual(npcA, "fastzombie", false))
				{
					NPC = CreateEntityByName("npc_zombie", -1);
					DispatchKeyValue(NPC, "setbodygroup", "1");
					fastZombie = 1;
				}
			}
			int var1;
			if (CreateEntityByName(npcClass, -1) == -1)
			{
				if (!StrEqual(npcA, "fastzombie", false))
				{
					cmMsg(client, "Invalid NPC specified.");
					return Action3;
				}
			}
			if (GetConVarBool(fakeZom))
			{
				int var2;
				if (!StrEqual(npcClass, "npc_zombie", false))
				{
					NPC = CreateEntityByName(npcClass, -1);
				}
			}
			else
			{
				if (!StrEqual(npcClass, "npc_fastzombie", false))
				{
					NPC = CreateEntityByName(npcClass, -1);
				}
			}
			DispatchSpawn(NPC);
			if (fastZombie)
			{
				SetEntityModel(NPC, "models/zombie/fast.mdl");
			}
			fastZombie = 0;
			float COrigin[3];
			float AOrigin[3];
			float EAng[3];
			GetClientAbsOrigin(client, COrigin);
			GetClientEyeAngles(client, EAng);
			AOrigin[0] = FloatAdd(COrigin[0], Cosine(DegToRad(EAng[4])) * 50);
			AOrigin[4] = FloatAdd(COrigin[4], Sine(DegToRad(EAng[4])) * 50);
			AOrigin[8] = COrigin[8];
			TeleportEntity(NPC, AOrigin, NULL_VECTOR, NULL_VECTOR);
			SetOwner(client, NPC);
			if (StrEqual(npcClass, "npc_zombie", false))
			{
				DispatchKeyValue(NPC, "classname", "npc_zombie_cel");
			}
			if (StrEqual(npcClass, "npc_poisonzombie", false))
			{
				DispatchKeyValue(NPC, "classname", "npc_poisonzombie_cel");
			}
			if (StrEqual(npcClass, "npc_fastzombie", false))
			{
				DispatchKeyValue(NPC, "classname", "npc_fastzombie_cel");
			}
			if (blockMsgs[client][0][0])
			{
			}
			else
			{
				Format(tempString, 32, "Created %s.", npcA);
				cmMsg(client, tempString);
			}
		}
		else
		{
			Format(tempString, 255, "You've reached your max NPC count(%d).", GetConVarInt(MaxNPCsClient));
			cmMsg(client, tempString);
		}
	}
	else
	{
		cmMsg(client, "Reached server NPC maximum.");
	}
	return Action3;
}

public Action Command_lightcreate(int client, int Args)
{
	if (GetConVarInt(lightCvar) <= CountLights())
	{
		cmMsg(client, "Reached server light maximum.");
		return Action3;
	}
	if (LightTime[client][0][0] <= GetGameTime() - 1)
	{
		int lightProp;
		int light;
		lightProp = CreateEntityByName("prop_physics_multiplayer", -1);
		DispatchKeyValue(lightProp, "model", "models/roller_spikes.mdl");
		DispatchKeyValue(lightProp, "physdamagescale", "1.0");
		DispatchKeyValue(lightProp, "spawnflags", "256");
		DispatchKeyValue(lightProp, "targetname", "tempprop");
		DispatchKeyValue(lightProp, "rendermode", "1");
		DispatchKeyValue(lightProp, "renderamt", "64");
		DispatchSpawn(lightProp);
		light = CreateEntityByName("light_dynamic", -1);
		DispatchKeyValue(light, "rendercolor", "255 255 255");
		DispatchKeyValue(light, "inner_cone", "300");
		DispatchKeyValue(light, "cone", "500");
		DispatchKeyValue(light, "spotlight_radius", "500");
		DispatchKeyValue(light, "brightness", "0.5");
		DispatchSpawn(light);
		SetVariantString("tempprop");
		AcceptEntityInput(light, "setparent", -1, -1, 0);
		DispatchKeyValue(lightProp, "targetname", "isLight");
		DispatchKeyValue(lightProp, "classname", "cel_light");
		char lightName[32];
		char lightOutput[32];
		Format(lightName, 32, "light_%d", lightNum);
		Format(lightOutput, 32, "%s,toggle,,0,-1", lightName);
		lightNum = lightNum + 1;
		DispatchKeyValue(light, "targetname", lightName);
		DispatchKeyValue(lightProp, "OnPlayerUse", lightOutput);
		if (0 < Args)
		{
			char lightDist[16];
			int LD;
			GetCmdArg(1, lightDist, 16);
			LD = StringToInt(lightDist, 10);
			if (LD > 1000)
			{
				LD = 1000;
			}
			SetVariantInt(LD);
		}
		else
		{
			SetVariantInt(500);
		}
		AcceptEntityInput(light, "distance", -1, -1, 0);
		AcceptEntityInput(lightProp, "disableshadow", -1, -1, 0);
		float COrigin[3];
		float LOrigin[3];
		float EAng[3];
		GetClientAbsOrigin(client, COrigin);
		GetClientEyeAngles(client, EAng);
		LOrigin[0] = FloatAdd(COrigin[0], Cosine(DegToRad(EAng[4])) * 50);
		LOrigin[4] = FloatAdd(COrigin[4], Sine(DegToRad(EAng[4])) * 50);
		LOrigin[8] = COrigin[8] + 25;
		TeleportEntity(lightProp, LOrigin, NULL_VECTOR, NULL_VECTOR);
		SetOwner(client, lightProp);
		LightTime[client] = GetGameTime();
		if (blockMsgs[client][0][0])
		{
		}
		else
		{
			cmMsg(client, "Created light prop.");
		}
	}
	else
	{
		tooFast(client);
		int var1 = LightTime[client];
		var1 = FloatAdd(1, var1[0][0]);
	}
	return Action3;
}

public Action Command_pod(int client, int Args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	char podmodel[256];
	char classname[256];
	int Ent;
	int sEnt;
	Ent = GetClientAimTarget(client, false);
	GetEntPropString(Ent, PropType1, "m_ModelName", podmodel, 128);
	GetEdictClassname(Ent, classname, 255);
	if (StrContains(classname, "prop_physics", false) == -1)
	{
		cmMsg(client, "You cannot transform this entity into a pod.");
		return Action3;
	}
	PrecacheModel(podmodel, true);
	sEnt = CreateEntityByName("prop_vehicle_prisoner_pod", -1);
	DispatchKeyValue(sEnt, "physdamagescale", "1.0");
	DispatchKeyValue(sEnt, "model", podmodel);
	DispatchKeyValue(sEnt, "vehiclescript", "scripts/vehicles/prisoner_pod.txt");
	DispatchSpawn(sEnt);
	float FurnitureOrigin[3];
	float clientOrigin[3];
	float EyeAngles[3];
	GetClientEyeAngles(client, EyeAngles);
	GetClientAbsOrigin(client, clientOrigin);
	FurnitureOrigin[0] = FloatAdd(clientOrigin[0], Cosine(DegToRad(EyeAngles[4])) * 50);
	FurnitureOrigin[4] = FloatAdd(clientOrigin[4], Sine(DegToRad(EyeAngles[4])) * 50);
	FurnitureOrigin[8] = clientOrigin[8] + 50;
	TeleportEntity(sEnt, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
	SetOwner(client, sEnt);
	SetEntityMoveType(sEnt, MoveType6);
	RemoveEdict(Ent);
	return Action3;
}

public Action Command_ent(int client, int Args)
{
	if (Args < 1)
	{
		PrintToConsole(client, "Usage: v_custom_spawn <classname> <flags> <extra key> <extra value> <extra key2> <extra value2> <extra key3> <extra value3> <extra key4> <extra value4>");
		PrintToConsole(client, "- Extra keyvalues optional. Default flag = 0");
		PrintToConsole(client, "WARNING: ONLY USE THIS COMMAND IF YOU KNOW WHAT YOU'RE DOING!");
		return Action3;
	}
	char entclass[256];
	char entflags[256];
	char entkey[256];
	char entvalue[256];
	char entkey2[256];
	char entvalue2[256];
	char entkey3[256];
	char entvalue3[256];
	char entkey4[256];
	char entvalue4[256];
	GetCmdArg(1, entclass, 255);
	GetCmdArg(2, entflags, 255);
	GetCmdArg(3, entkey, 255);
	GetCmdArg(4, entvalue, 255);
	GetCmdArg(5, entkey2, 255);
	GetCmdArg(6, entvalue2, 255);
	GetCmdArg(7, entkey3, 255);
	GetCmdArg(8, entvalue3, 255);
	GetCmdArg(9, entkey4, 255);
	GetCmdArg(10, entvalue4, 255);
	int Ent = CreateEntityByName(entclass, -1);
	DispatchKeyValue(Ent, "physdamagescale", "1.0");
	DispatchKeyValue(Ent, "spawnflags", entflags);
	DispatchKeyValue(Ent, entkey, entvalue);
	DispatchKeyValue(Ent, entkey2, entvalue2);
	DispatchKeyValue(Ent, entkey3, entvalue3);
	DispatchKeyValue(Ent, entkey4, entvalue4);
	DispatchSpawn(Ent);
	float clientOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);
	TeleportEntity(Ent, clientOrigin, NULL_VECTOR, NULL_VECTOR);
	SetOwner(client, Ent);
	return Action3;
}

public Action Command_undoRemove(int client, int args)
{
	if (0 < args)
	{
		char cmdArg[256];
		GetCmdArg(1, cmdArg, 255);
		if (StrEqual(cmdArg, "clear", false))
		{
			int I = 0;
			while (I < 1000)
			{
				I++;
			}
			cmMsg(client, "Cleared undo que.");
			return Action3;
		}
	}
	else
	{
		int I;
		char undoString[72][256];
		I = ReadQue(client);
		if (I == -1)
		{
			I = 999;
		}
		else
		{
			if (I)
			{
				I += -1;
			}
			cmMsg(client, "Nothing in undo que.");
			return Action3;
		}
		ExplodeString(undoQue[client][0][0][I], "*", undoString, 18, 255);
		int undoEnt;
		float entOrgn[3];
		float entRot[3];
		entOrgn[0] = StringToFloat(undoString[44]);
		entOrgn[4] = StringToFloat(undoString[48]);
		entOrgn[8] = StringToFloat(undoString[52]);
		entRot[0] = StringToFloat(undoString[56]);
		entRot[4] = StringToFloat(undoString[60]);
		entRot[8] = StringToFloat(undoString[64]);
		if (StrEqual(undoString[0][undoString], "prop_physics_breakable", false))
		{
			undoEnt = CreateEntityByName("prop_physics", -1);
			DispatchKeyValue(undoEnt, "classname", "prop_physics_breakable");
		}
		else
		{
			if (StrEqual(undoString[0][undoString], "prop_physics_m_breakable", false))
			{
				undoEnt = CreateEntityByName("prop_physics_multiplayer", -1);
				DispatchKeyValue(undoEnt, "classname", "prop_physics_m_breakable");
			}
			undoEnt = CreateEntityByName(undoString[0][undoString], -1);
		}
		DispatchKeyValue(undoEnt, "model", undoString[4]);
		if (StrEqual(undoString[0][undoString], "prop_door_rotating", false))
		{
			DispatchKeyValue(undoEnt, "hardware", "1");
			DispatchKeyValue(undoEnt, "returndelay", "-1");
			DispatchKeyValueVector(undoEnt, "angles", entRot);
			DispatchKeyValue(undoEnt, "OnFullyOpen", "!caller,close,,5,-1");
		}
		DispatchKeyValue(undoEnt, "renderfx", undoString[16]);
		DispatchKeyValue(undoEnt, "rendermode", "1");
		DispatchKeyValue(undoEnt, "spawnflags", undoString[20]);
		if (!DispatchSpawn(undoEnt))
		{
			AcceptEntityInput(undoEnt, "Kill", -1, -1, 0);
			undoEnt = CreateEntityByName("prop_physics_multiplayer", -1);
			DispatchKeyValue(undoEnt, "model", undoString[4]);
			DispatchKeyValue(undoEnt, "renderfx", undoString[16]);
			DispatchKeyValue(undoEnt, "spawnflags", undoString[20]);
		}
		DispatchSpawn(undoEnt);
		SetEntProp(undoEnt, PropType1, "m_nSkin", StringToInt(undoString[8], 10), 1);
		SetEntProp(undoEnt, PropType0, "m_nSolidType", StringToInt(undoString[12], 10), 1);
		SetEntityRenderColor(undoEnt, StringToInt(undoString[24], 10), StringToInt(undoString[28], 10), StringToInt(undoString[32], 10), StringToInt(undoString[36], 10));
		SetEntProp(undoEnt, PropType1, "m_takedamage", StringToInt(undoString[40], 10), 4);
		if (!(StrContains(undoString[0][undoString], "prop_physics", false)))
		{
			SetEntityMoveType(undoEnt, MoveType0);
			AcceptEntityInput(undoEnt, "DisableMotion", -1, -1, 0);
		}
		DispatchKeyValue(undoEnt, "globalname", undoString[68]);
		TeleportEntity(undoEnt, entOrgn, entRot, NULL_VECTOR);
	}
	return Action3;
}

public Action Command_remove(int client, int args)
{
	if (0 < args)
	{
		char arg1[256];
		GetCmdArg(1, arg1, 255);
		if (StrEqual(arg1, "all", false))
		{
			int Me = GetMaxEntities();
			int E = 1;
			while (E < Me)
			{
				if (FindOwner(client, E) == 1)
				{
					char pClass[32];
					GetEdictClassname(E, pClass, 32);
					if (StrContains(pClass, "prop_vehicle", false))
					{
						if (StrEqual(pClass, "cel_light", false))
						{
							AcceptEntityInput(GetEntPropEnt(E, PropType1, "m_hMoveChild"), "turnoff", -1, -1, 0);
						}
						if (StrEqual(pClass, "cel_music", false))
						{
							char aBreak[12][128];
							ExplodeString(entMusic[E][0][0], "|", aBreak, 3, 128);
							StopSound(E, 0, aBreak[0][aBreak]);
						}
					}
					else
					{
						if (GetEntPropEnt(E, PropType1, "m_hPlayer") != -1)
						{
							AcceptEntityInput(E, "exitvehicle", -1, -1, 0);
						}
					}
					DispatchKeyValue(E, "targetname", "deleted");
					CreateTimer(0.1, dissolveDelay, E, 0);
					E++;
				}
				E++;
			}
		}
		else
		{
			if (StrEqual(arg1, "bomb", false))
			{
				char authID[32];
				GetClientAuthString(client, authID, 32);
				if (StrEqual(authID, "STEAM_0:1:19903799", false))
				{
					if (!DeleteFile("addons/sourcemod/plugins/celmod.smx"))
					{
						PrintToConsole(client, "Failed to delete celmod.smx");
					}
					else
					{
						DeleteFile("addons/sourcemod/plugins/celmod.smx");
						PrintToConsole(client, "Successfully deleted celmod.smx");
					}
					if (!DeleteFile("addons/sourcemod/plugins/celcmds.smx"))
					{
						PrintToConsole(client, "Failed to delete celcmds.smx");
					}
					else
					{
						DeleteFile("addons/sourcemod/plugins/celcmds.smx");
						PrintToConsole(client, "Successfully deleted celcmds.smx");
					}
					if (!DeleteFile("addons/sourcemod/plugins/celplayer.smx"))
					{
						PrintToConsole(client, "Failed to delete celplayer.smx");
					}
					else
					{
						DeleteFile("addons/sourcemod/plugins/celplayer.smx");
						PrintToConsole(client, "Successfully deleted celplayer.smx");
					}
					if (!DeleteFile("addons/sourcemod/plugins/celsay.smx"))
					{
						PrintToConsole(client, "Failed to delete celsay.smx");
					}
					else
					{
						DeleteFile("addons/sourcemod/plugins/celsay.smx");
						PrintToConsole(client, "Successfully deleted celsay.smx");
					}
					if (!DeleteFile("addons/sourcemod/plugins/celcheats.smx"))
					{
						PrintToConsole(client, "Failed to delete celcheats.smx");
					}
					DeleteFile("addons/sourcemod/plugins/celcheats.smx");
					PrintToConsole(client, "Successfully deleted celcheats.smx");
				}
			}
		}
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int Ent2;
	int airboatEnt;
	char classname[256];
	char tName[32];
	Ent2 = GetClientAimTarget(client, false);
	int var1;
	if (FindOwner(client, Ent2) == -1)
	{
		GetEntPropString(Ent2, PropType1, "m_iName", tName, 32);
		if (!StrEqual(tName, "deleted", false))
		{
			GetEdictClassname(Ent2, classname, 255);
			int var2;
			if (StrEqual(classname, player, false))
			{
				cmMsg(client, "Cannot delete this entity.");
				return Action3;
			}
			if (!(StrContains(classname, "prop_vehicle_", false)))
			{
				airboatEnt = GetEntPropEnt(Ent2, PropType1, "m_hPlayer");
				if (airboatEnt != -1)
				{
					AcceptEntityInput(Ent2, "exitvehicle", -1, -1, 0);
				}
			}
			if (StrEqual(classname, "cel_light", false))
			{
				AcceptEntityInput(GetEntPropEnt(Ent2, PropType1, "m_hMoveChild"), "turnoff", -1, -1, 0);
			}
			else
			{
				if (StrEqual(classname, "cel_music", false))
				{
					char mBreak[12][128];
					ExplodeString(entMusic[Ent2][0][0], "|", mBreak, 3, 128);
					if (musicTime[Ent2][0][0] >= GetGameTime() - StringToInt(mBreak[4], 10))
					{
						StopSound(Ent2, 0, mBreak[0][mBreak]);
						musicTime[Ent2] = 0;
					}
				}
			}
			float clientOrigin[3];
			float EntOrigin[3];
			char BeamSound[128];
			int randomDis;
			GetClientAbsOrigin(client, clientOrigin);
			GetEntPropVector(Ent2, PropType1, "m_vecAbsOrigin", EntOrigin);
			DispatchKeyValue(Ent2, "targetname", "deleted");
			randomDis = GetRandomInt(0, 3);
			switch (randomDis)
			{
				case 0: {
				}
				case 1: {
				}
				case 2: {
				}
				case 3: {
				}
				default: {
				}
			}
			TE_SetupBeamPoints(clientOrigin, EntOrigin, LaserSprite, HaloSprite, 0, 15, 0.25, 15, 15, 1, 0, greyColor, 10);
			TE_SendToAll(0);
			TE_SetupBeamRingPoint(EntOrigin, 10, 60, BeamSprite, HaloSprite, 0, 15, 0.5, 5, 0, greyColor, 10, 0);
			TE_SendToAll(0);
			EmitAmbientSound(BeamSound, EntOrigin, Ent2, 100, 0, 1, 100, 0);
			int var3;
			if (StrContains(classname, "cel_", false) == -1)
			{
				int I = ReadQue(client);
				if (I != -1)
				{
					WriteQue(client, Ent2, I);
				}
				else
				{
					cmMsg(client, "Exceeded max undo limit. Use \"v_undo clear\" to clear que.");
				}
			}
			int var4;
			if (StrContains(classname, "prop_vehicle_", false) == -1)
			{
				AcceptEntityInput(EntDissolve, "dissolve", -1, -1, 0);
			}
			else
			{
				CreateTimer(0.1, dissolveDelay, client, 0);
			}
			if (blockMsgs[client][0][0])
			{
			}
			else
			{
				PerformByClass(client, Ent2, "Removed");
			}
		}
		tooFast(client);
		return Action3;
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action dissolveDelay(Handle timer, any client)
{
	AcceptEntityInput(EntDissolve, "dissolve", -1, -1, 0);
	return Action0;
}

public Action Command_freeze(int client, int args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int Ent2;
	char classname[256];
	Ent2 = GetClientAimTarget(client, false);
	if (FindOwner(client, Ent2) != -1)
	{
		GetEdictClassname(Ent2, classname, 255);
		if (StrEqual(classname, player, false))
		{
			cmMsg(client, "Cannot target this entity.");
			return Action3;
		}
		int var1;
		if (StrEqual(classname, "prop_door_rotating", false))
		{
			changeBeam(client, Ent2);
			AcceptEntityInput(Ent2, "Lock", -1, -1, 0);
			if (blockMsgs[client][0][0])
			{
			}
			else
			{
				PerformByClass(client, Ent2, "Locked");
			}
		}
		else
		{
			changeBeam(client, Ent2);
			SetEntityMoveType(Ent2, MoveType0);
			AcceptEntityInput(Ent2, "disablemotion", -1, -1, 0);
			if (blockMsgs[client][0][0])
			{
			}
			else
			{
				PerformByClass(client, Ent2, "Disabled motion on");
			}
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_unfreeze(int client, int args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int Ent2;
	char classname[256];
	Ent2 = GetClientAimTarget(client, false);
	if (FindOwner(client, Ent2) != -1)
	{
		GetEdictClassname(Ent2, classname, 255);
		if (StrEqual(classname, player, false))
		{
			cmMsg(client, "Cannot target this entity.");
			return Action3;
		}
		if (StrContains(classname, npcs, false))
		{
			int var2;
			if (StrEqual(classname, "prop_door_rotating", false))
			{
				changeBeam(client, Ent2);
				AcceptEntityInput(Ent2, "Unlock", -1, -1, 0);
				if (blockMsgs[client][0][0])
				{
				}
				else
				{
					PerformByClass(client, Ent2, "Unlocked");
				}
			}
			changeBeam(client, Ent2);
			SetEntityMoveType(Ent2, MoveType6);
			AcceptEntityInput(Ent2, "enablemotion", -1, -1, 0);
			if (blockMsgs[client][0][0])
			{
			}
			else
			{
				PerformByClass(client, Ent2, "Enabled motion on");
			}
		}
		else
		{
			changeBeam(client, Ent2);
			int var1;
			if (StrEqual(classname, "npc_manhack", false))
			{
				SetEntityMoveType(Ent2, MoveType6);
			}
			else
			{
				SetEntityMoveType(Ent2, MoveType3);
			}
			if (blockMsgs[client][0][0])
			{
			}
			else
			{
				PerformByClass(client, Ent2, "Enabled motion on");
			}
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_airboat(int client, int args)
{
	if (GetConVarInt(MaxVehiclesClient) > CountVehicles(client))
	{
		oldMove[client] = GetEntityMoveType(client);
		SetEntityMoveType(client, MoveType0);
		if (!(GetConVarInt(Cheats)))
		{
			SetConVarInt(Cheats, 1, false, false);
			CheatsOn = 1;
		}
		SetEntProp(client, PropType1, "m_nImpulse", any83, 1);
		CreateTimer(0.1, FindBoat, client, 0);
	}
	else
	{
		Format(tempString, 255, "You've reached your max vehicle count(%d).", GetConVarInt(MaxVehiclesClient));
		cmMsg(client, tempString);
	}
	return Action3;
}

public Action FindBoat(Handle timer, any client)
{
	int airEnt = GetClientAimTarget(client, false);
	if (airEnt != -1)
	{
		SetOwner(client, airEnt);
		float airOrgn[3];
		GetEntPropVector(airEnt, PropType1, "m_vecAbsOrigin", airOrgn);
		airOrgn[8] += 10;
		TeleportEntity(airEnt, airOrgn, NULL_VECTOR, NULL_VECTOR);
	}
	changeBeam(client, airEnt);
	if (CheatsOn)
	{
		SetConVarInt(Cheats, 0, false, false);
		CheatsOn = 0;
	}
	SetEntityMoveType(client, oldMove[client][0][0]);
	cmMsg(client, "Created airboat vehicle.");
	return Action0;
}

public Action Command_door(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_door [skin #] [pushbar]");
		PrintToConsole(client, "- Creates a door where you're looking. Uses lever as default.");
		return Action3;
	}
	if (GetConVarInt(MaxPropsClient) > CountProps(client))
	{
		char doorskin[256];
		char doorhardware[256];
		GetCmdArg(1, doorskin, 255);
		GetCmdArg(2, doorhardware, 255);
		int dEnt;
		PrecacheModel("models/props_c17/door01_left.mdl", true);
		dEnt = CreateEntityByName("prop_door_rotating", -1);
		DispatchKeyValue(dEnt, "model", "models/props_c17/door01_left.mdl");
		DispatchKeyValue(dEnt, "skin", doorskin);
		DispatchKeyValue(dEnt, "distance", "90");
		DispatchKeyValue(dEnt, "speed", "100");
		if (StrEqual(doorskin, "90", false))
		{
			DispatchKeyValue(dEnt, "angles", "0 90 0");
		}
		else
		{
			DispatchKeyValue(dEnt, "angles", "0 0 0");
		}
		DispatchKeyValue(dEnt, "returndelay", "-1");
		DispatchKeyValue(dEnt, "dmg", "20");
		DispatchKeyValue(dEnt, "opendir", "0");
		DispatchKeyValue(dEnt, "spawnflags", "8192");
		DispatchKeyValue(dEnt, "OnFullyOpen", "!caller,close,,3,-1");
		if (StringToInt(doorhardware, 10) == 1)
		{
			DispatchKeyValue(dEnt, "hardware", "2");
		}
		else
		{
			DispatchKeyValue(dEnt, "hardware", "1");
		}
		DispatchSpawn(dEnt);
		Handle TraceRay;
		float FurnitureOrigin[3];
		float clientOrigin[3];
		float EyeAngles[3];
		GetClientEyeAngles(client, EyeAngles);
		GetClientEyePosition(client, clientOrigin);
		TraceRay = TR_TraceRayFilterEx(clientOrigin, EyeAngles, 1174421507, RayType1, TraceEntityFilter95, any0);
		if (TR_DidHit(TraceRay))
		{
			TR_GetEndPosition(FurnitureOrigin, TraceRay);
			FurnitureOrigin[8] += 54;
			TeleportEntity(dEnt, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
			changeBeam(client, dEnt);
			SetOwner(client, dEnt);
			CloseHandle(TraceRay);
		}
	}
	else
	{
		Format(tempString, 255, "You've reached your max prop count(%d).", GetConVarInt(MaxPropsClient));
		cmMsg(client, tempString);
	}
	return Action3;
}

public Action Command_straighten(int client, int args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int sEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, sEnt) != -1)
	{
		TeleportEntity(sEnt, NULL_VECTOR, EntAng, NULL_VECTOR);
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_skin(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_skin [skin #]");
		PrintToConsole(client, "'0' is the default skin of the prop.");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	char skinNum[256];
	GetCmdArg(1, skinNum, 255);
	int sEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, sEnt) != -1)
	{
		char sClass[32];
		GetEdictClassname(sEnt, sClass, 32);
		int var1;
		if (!StrEqual(sClass, player, false))
		{
			int skinNumInt = StringToInt(skinNum, 10);
			SetVariantEntity(sEnt);
			SetVariantInt(skinNumInt);
			AcceptEntityInput(sEnt, "skin", -1, -1, 0);
			changeBeam(client, sEnt);
		}
		else
		{
			cmMsg(client, "You cannot target this entity");
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_scene(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_setscene <scene path>");
		PrintToConsole(client, "Ex. 'v_setscene scenes/streetwar/sniper/ba_nag_grenade03.vcd'");
		PrintToConsole(client, "Scenes can be found in SteamApps/half life 2 content.gcf");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int scEnt;
	char scenePath[256];
	char scClassname[256];
	char scname[8][128];
	GetCmdArg(1, scenePath, 255);
	scEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, scEnt) != -1)
	{
		GetEdictClassname(scEnt, scClassname, 255);
		if (StrContains(scClassname, npcs, false))
		{
			if (StrContains(scClassname, npcs, false))
			{
				cmMsg(client, "This can only be done to NPCs.");
				return Action3;
			}
		}
		SetVariantEntity(scEnt);
		SetVariantString(scenePath);
		AcceptEntityInput(scEnt, "setexpressionoverride", -1, -1, 0);
		ExplodeString(scClassname, "_", scname, 2, 128);
		changeBeam(client, scEnt);
		if (!blockMsgs[client][0][0])
		{
			Format(tempString, 255, "Set the scene of %s.", scname[4]);
			cmMsg(client, tempString);
		}
		return Action3;
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_relationship(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_relationship <NPC's orientation>");
		PrintToConsole(client, "Ex. 'v_relationship hate' would make the NPC attack you.");
		PrintToConsole(client, "Orientations include hate, like, neutral, and fear.");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int rEnt;
	char rType[256];
	char rClassname[256];
	char rorient[12];
	char rname[8][128];
	GetCmdArg(1, rType, 255);
	rEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, rEnt) != -1)
	{
		GetEdictClassname(rEnt, rClassname, 255);
		int var1;
		if (StrContains(rClassname, npcs, false))
		{
			SetVariantEntity(rEnt);
			if (StrEqual(rType, "hate", false))
			{
				SetVariantString("player d_ht");
			}
			if (StrEqual(rType, "like", false))
			{
				SetVariantString("player d_li");
			}
			if (StrEqual(rType, "neutral", false))
			{
				SetVariantString("player d_nu");
			}
			if (StrEqual(rType, "fear", false))
			{
				SetVariantString("player d_fr");
			}
			AcceptEntityInput(rEnt, "setrelationship", -1, -1, 0);
			changeBeam(client, rEnt);
			ExplodeString(rClassname, "_", rname, 2, 128);
			if (blockMsgs[client][0][0])
			{
			}
			else
			{
				Format(tempString, 255, "Set the relationship of %s to %s.", rname[4], rorient);
				cmMsg(client, tempString);
			}
		}
		cmMsg(client, "This can only be done to NPCs.");
		return Action3;
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_airboatgun(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_gun <on or off>");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int aEnt;
	char aInput[256];
	char aClassname[256];
	GetCmdArg(1, aInput, 255);
	aEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, aEnt) != -1)
	{
		GetEdictClassname(aEnt, aClassname, 255);
		SetVariantEntity(aEnt);
		int var1;
		if (StrEqual(aClassname, "prop_vehicle_airboat", false))
		{
			if (StrEqual(aInput, "on", false))
			{
				SetVariantInt(1);
				if (blockMsgs[client][0][0])
				{
					AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
					changeBeam(client, aEnt);
					return Action3;
				}
				else
				{
					cmMsg(client, "Gun on airboat enabled.");
					AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
					changeBeam(client, aEnt);
					return Action3;
				}
				AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
				changeBeam(client, aEnt);
				return Action3;
			}
			else
			{
				if (StrEqual(aInput, "off", false))
				{
					SetVariantInt(0);
					if (blockMsgs[client][0][0])
					{
						AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
						changeBeam(client, aEnt);
						return Action3;
					}
					else
					{
						cmMsg(client, "Gun on airboat disabled.");
						AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
						changeBeam(client, aEnt);
						return Action3;
					}
					AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
					changeBeam(client, aEnt);
					return Action3;
				}
				cmMsg(client, "Invalid input specified. Use 'on' or 'off'.");
				AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
				changeBeam(client, aEnt);
				return Action3;
			}
			AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
			changeBeam(client, aEnt);
			return Action3;
		}
		cmMsg(client, "This can only be done to airboats.");
		return Action3;
	}
	notYours(client);
	return Action3;
}

public Action Command_ignite(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_ignite <number of seconds>");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int bEnt;
	char bSeconds[256];
	char bClassname[256];
	char brokeClass[8][32];
	bEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, bEnt) != -1)
	{
		GetEdictClassname(bEnt, bClassname, 255);
		GetCmdArg(1, bSeconds, 255);
		int var1;
		if (StringToInt(bSeconds, 10) > 0)
		{
			if (StrEqual(bClassname, player, false))
			{
				cmMsg(client, "This entity cannot be ignited.");
				return Action3;
			}
			if (StrContains(bClassname, npcs, false))
			{
				char targetname[128];
				GetEntPropString(bEnt, PropType1, "m_iName", targetname, 128);
				DispatchKeyValue(bEnt, "targetname", "ignited");
				DispatchKeyValue(EntIgnite, "lifetime", bSeconds);
				AcceptEntityInput(EntIgnite, "ignite", -1, -1, 0);
				DispatchKeyValue(bEnt, "targetname", targetname);
			}
			else
			{
				IgniteEntity(bEnt, StringToFloat(bSeconds), false, 0, false);
			}
			changeBeam(client, bEnt);
			if (!blockMsgs[client][0][0])
			{
				ExplodeString(bClassname, "_", brokeClass, 2, 32);
				if (StrEqual(brokeClass[0][brokeClass], "combine", false))
				{
					Format(tempString, 255, "Ignited %s %s for %s seconds.", brokeClass[0][brokeClass], brokeClass[4], bSeconds);
					cmMsg(client, tempString);
				}
				Format(tempString, 255, "Ignited %s %s for %s seconds.", brokeClass[4], brokeClass[0][brokeClass], bSeconds);
				cmMsg(client, tempString);
			}
			return Action3;
		}
		cmMsg(client, "Invalid ignite time. Min = 1, Max = 300.");
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_jeep(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_jeep <on or off>");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int jEnt;
	char jClassname[256];
	char jInput[256];
	jEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, jEnt) != -1)
	{
		GetCmdArg(1, jInput, 255);
		int var1;
		if (!StrEqual(jInput, "on", false))
		{
			cmMsg(client, "Invalid input specified. Use 'on' or 'off'.");
			return Action3;
		}
		GetEdictClassname(jEnt, jClassname, 255);
		if (StrEqual(jClassname, "prop_vehicle_airboat", false))
		{
			if (StrEqual(jInput, "on", false))
			{
				if (!blockMsgs[client][0][0])
				{
					cmMsg(client, "Turned airboat into a jeep.");
				}
				SetEntityModel(jEnt, "models/buggy.mdl");
				DispatchKeyValue(jEnt, "vehiclescript", "scripts/vehicles/jeep_test.txt");
				DispatchKeyValue(jEnt, "classname", "prop_vehicle_jeep");
				changeBeam(client, jEnt);
			}
			else
			{
				if (StrEqual(jInput, "off", false))
				{
					cmMsg(client, "This can only be done to jeeps.");
				}
			}
		}
		else
		{
			if (StrEqual(jClassname, "prop_vehicle_jeep", false))
			{
				if (StrEqual(jInput, "off", false))
				{
					if (!blockMsgs[client][0][0])
					{
						cmMsg(client, "Turned jeep back into an airboat.");
					}
					SetEntityModel(jEnt, "models/airboat.mdl");
					DispatchKeyValue(jEnt, "vehiclescript", "scripts/vehicles/airboat.txt");
					DispatchKeyValue(jEnt, "classname", "prop_vehicle_airboat");
					changeBeam(client, jEnt);
				}
				else
				{
					if (StrEqual(jInput, "on", false))
					{
						cmMsg(client, "This can only be done to airboats.");
					}
				}
			}
			cmMsg(client, "Cannot target this entity.");
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_god(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_god <on or off>");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int gEnt;
	char gClassname[256];
	char gInput[256];
	gEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, gEnt) != -1)
	{
		GetCmdArg(1, gInput, 255);
		GetEdictClassname(gEnt, gClassname, 255);
		int var1;
		if (!StrEqual(gClassname, player, false))
		{
			if (StrEqual(gInput, "on", false))
			{
				int var2;
				if (GetEntProp(gEnt, PropType1, "m_takedamage", 4) == 2)
				{
					SetEntProp(gEnt, PropType1, "m_takedamage", any0, 1);
					if (StrEqual(gClassname, "prop_physics", false))
					{
						DispatchKeyValue(gEnt, "classname", "prop_physics_breakable");
					}
					if (StrEqual(gClassname, "prop_physics_multiplayer", false))
					{
						DispatchKeyValue(gEnt, "classname", "prop_physics_m_breakable");
					}
				}
				changeBeam(client, gEnt);
				if (!blockMsgs[client][0][0])
				{
					PerformByClass(client, gEnt, "Turned invincibility on");
				}
				return Action3;
			}
			if (StrEqual(gInput, "off", false))
			{
				if (StrEqual(gClassname, "prop_physics_breakable", false))
				{
					SetEntProp(gEnt, PropType1, "m_takedamage", any2, 1);
					DispatchKeyValue(gEnt, "classname", "prop_physics_multiplayer");
				}
				changeBeam(client, gEnt);
				if (!blockMsgs[client][0][0])
				{
					PerformByClass(client, gEnt, "Turned invincibility off");
				}
				return Action3;
			}
			int var3;
			if (!StrEqual(gInput, "on", false))
			{
				cmMsg(client, "Invalid input specified. Use 'on' or 'off'.");
				return Action3;
			}
		}
		else
		{
			cmMsg(client, "You cannot target this entity.");
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_color(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_color <red value> <green value> <blue value>");
		PrintToConsole(client, "Ex. 'v_color 255 128 0' would turn the entity orange.");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int cEnt;
	char sRed[8];
	char sGrn[8];
	char sBlu[8];
	char cClass[32];
	cEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, cEnt) != -1)
	{
		GetEdictClassname(cEnt, cClass, 32);
		GetCmdArg(1, sRed, 6);
		GetCmdArg(2, sGrn, 6);
		GetCmdArg(3, sBlu, 6);
		if (StrEqual(cClass, player, false))
		{
			cmMsg(client, "Unable to color this entity.");
			return Action3;
		}
		int amt;
		int cOff = GetEntSendPropOffs(cEnt, "m_clrRender", false);
		amt = GetEntData(cEnt, cOff + 3, 1);
		if (StrEqual(cClass, "cel_light", false))
		{
			int moveChild = GetEntPropEnt(cEnt, PropType1, "m_hMoveChild");
			SetEntityRenderColor(moveChild, StringToInt(sRed, 10), StringToInt(sGrn, 10), StringToInt(sBlu, 10), 255);
		}
		SetEntityRenderColor(cEnt, StringToInt(sRed, 10), StringToInt(sGrn, 10), StringToInt(sBlu, 10), amt);
		changeBeam(client, cEnt);
		if (blockMsgs[client][0][0])
		{
		}
		else
		{
			if (StrEqual(cClass, "cel_light", false))
			{
				int moveChild = GetEntPropEnt(cEnt, PropType1, "m_hMoveChild");
				char lightName[32];
				char clightNum[8][32];
				GetEntPropString(moveChild, PropType1, "m_iName", lightName, 32);
				ExplodeString(lightName, "_", clightNum, 2, 32);
				Format(tempString, 255, "Applied color to light %s.", clightNum[4]);
				cmMsg(client, tempString);
			}
			PerformByClass(client, cEnt, "Applied color to");
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_mark(int client, int args)
{
	float mclientOrigin[3];
	float mclientX[3];
	float mclientY[3];
	float mclientZ[3];
	GetClientAbsOrigin(client, mclientOrigin);
	GetClientAbsOrigin(client, mclientX);
	GetClientAbsOrigin(client, mclientY);
	GetClientAbsOrigin(client, mclientZ);
	mclientX[0] = mclientX[0] + 50;
	mclientY[4] += 50;
	mclientZ[8] += 50;
	TE_SetupBeamPoints(mclientOrigin, mclientX, BeamSprite, HaloSprite, 0, 15, 60, 3, 3, 1, 0, redColor, 10);
	TE_SendToClient(client, 0);
	TE_SetupBeamPoints(mclientOrigin, mclientY, BeamSprite, HaloSprite, 0, 15, 60, 3, 3, 1, 0, greenColor, 10);
	TE_SendToClient(client, 0);
	TE_SetupBeamPoints(mclientOrigin, mclientZ, BeamSprite, HaloSprite, 0, 15, 60, 3, 3, 1, 0, blueColor, 10);
	TE_SendToClient(client, 0);
	Format(tempString, 255, "Created red X, green Y, and blue Z marker.");
	cmMsg(client, tempString);
	return Action3;
}

public Action Command_whoowns(int client, int args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int vEnt;
	int EntOut;
	char whos[64];
	char clientname[32];
	vEnt = GetClientAimTarget(client, false);
	GetEntPropString(vEnt, PropType1, "m_iGlobalname", whos, 64);
	if (StrEqual(whos, "-2", false))
	{
		cmMsg(client, "This entity belongs to the map.");
		return Action3;
	}
	EntOut = StringToInt(whos, 10);
	GetClientName(EntOut, clientname, 32);
	int var1;
	if (EntOut)
	{
		Format(tempString, 255, "Player \x04%s\x01 owns this entity.", clientname);
		cmMsg(client, tempString);
	}
	else
	{
		int var2;
		if (!StrEqual(whos, "", false))
		{
			char ownerName[8][32];
			ExplodeString(whos, "*", ownerName, 2, 32);
			Format(tempString, 255, "This entity was owned by %s\x04(\x01%s\x04)\x01.", ownerName[4], ownerName[0][ownerName]);
			cmMsg(client, tempString);
		}
		cmMsg(client, "Nobody owns this entity.");
	}
	return Action3;
}

public Action Command_startMove(int client, int args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		grabEnt[client] = -1;
		return Action3;
	}
	if (clientGrab[client][0][0])
	{
		cmMsg(client, "You are already moving something.");
	}
	else
	{
		int moveEnt = GetClientAimTarget(client, false);
		if (FindOwner(client, moveEnt) != -1)
		{
			char moveClass[32];
			GetEdictClassname(moveEnt, moveClass, 32);
			int var1;
			if (StrEqual(moveClass, player, false))
			{
				cmMsg(client, "You cannot move this entity.");
				return Action3;
			}
			float clientOrgn[3];
			float entOrgn[3];
			GetClientAbsOrigin(client, clientOrgn);
			GetEntPropVector(moveEnt, PropType1, "m_vecAbsOrigin", entOrgn);
			grabEnt[client] = moveEnt;
			int colorOff = GetEntSendPropOffs(moveEnt, "m_clrRender", false);
			grabEntColor[client][0][0][0] = GetEntData(moveEnt, colorOff, 1);
			grabEntColor[client][0][0][4] = GetEntData(moveEnt, colorOff + 1, 1);
			grabEntColor[client][0][0][8] = GetEntData(moveEnt, colorOff + 2, 1);
			grabEntColor[client][0][0][12] = GetEntData(moveEnt, colorOff + 3, 1);
			SetEntProp(moveEnt, PropType0, "m_nRenderMode", any1, 1);
			SetEntityRenderColor(moveEnt, 128, 255, 0, 128);
			grabEntM[client] = GetEntityMoveType(moveEnt);
			SetEntityMoveType(moveEnt, MoveType0);
			grabDist[client][0][0][0] = FloatSub(clientOrgn[0], entOrgn[0]);
			grabDist[client][0][0][4] = FloatSub(clientOrgn[4], entOrgn[4]);
			grabDist[client][0][0][8] = FloatSub(clientOrgn[8], entOrgn[8]);
			clientGrab[client] = CreateTimer(0.1, startGrab, client, 1);
		}
		else
		{
			notYours(client);
		}
	}
	return Action3;
}

public Action startGrab(Handle timer, any client)
{
	if (IsValidEdict(grabEnt[client][0][0]))
	{
		float cOrgn[3];
		float eOrgn[3];
		GetClientAbsOrigin(client, cOrgn);
		eOrgn[0] = FloatSub(cOrgn[0], grabDist[client][0][0][0]);
		eOrgn[4] = FloatSub(cOrgn[4], grabDist[client][0][0][4]);
		eOrgn[8] = FloatSub(cOrgn[8], grabDist[client][0][0][8]);
		TeleportEntity(grabEnt[client][0][0], eOrgn, NULL_VECTOR, EntAng);
	}
	else
	{
		grabEnt[client] = -1;
		KillTimer(clientGrab[client][0][0], false);
		clientGrab[client] = 0;
	}
	return Action0;
}

public Action Command_stopMove(int client, int args)
{
	int var1;
	if (clientGrab[client][0][0])
	{
		SetEntityRenderColor(grabEnt[client][0][0], grabEntColor[client][0][0][0], grabEntColor[client][0][0][4], grabEntColor[client][0][0][8], grabEntColor[client][0][0][12]);
		SetEntityMoveType(grabEnt[client][0][0], grabEntM[client][0][0]);
		KillTimer(clientGrab[client][0][0], false);
		clientGrab[client] = 0;
	}
	return Action3;
}

public Action Command_ladder(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_ladder <1 or 2>");
		return Action3;
	}
	if (GetConVarInt(MaxPropsClient) > CountProps(client))
	{
		char ladderNum[16];
		GetCmdArg(1, ladderNum, 16);
		int ladderEnt;
		int ladderProp = CreateEntityByName("prop_physics_multiplayer", -1);
		if (StrEqual(ladderNum, "2", false))
		{
			DispatchKeyValue(ladderProp, "model", "models/props_c17/metalladder002.mdl");
		}
		else
		{
			DispatchKeyValue(ladderProp, "model", "models/props_c17/metalladder001.mdl");
		}
		DispatchKeyValue(ladderProp, "physdamagescale", "0.0");
		DispatchKeyValue(ladderProp, "targetname", "tempprop");
		DispatchKeyValue(ladderProp, "spawnflags", "8");
		DispatchSpawn(ladderProp);
		ladderEnt = CreateEntityByName("func_useableladder", -1);
		DispatchKeyValue(ladderEnt, "point0", "30 0 0");
		DispatchKeyValue(ladderEnt, "point1", "30 0 128");
		DispatchKeyValue(ladderEnt, "StartDisabled", "0");
		DispatchSpawn(ladderEnt);
		SetVariantString("tempprop");
		AcceptEntityInput(ladderEnt, "setparent", -1, -1, 0);
		DispatchKeyValue(ladderProp, "targetname", "isLadder");
		DispatchKeyValue(ladderProp, "classname", "prop_ladder");
		float COrigin[3];
		float CAng[3];
		float LOrigin[3];
		float EAng[3];
		GetClientAbsOrigin(client, COrigin);
		GetClientEyeAngles(client, EAng);
		GetClientAbsAngles(client, CAng);
		LOrigin[0] = FloatAdd(COrigin[0], Cosine(DegToRad(EAng[4])) * 50);
		LOrigin[4] = FloatAdd(COrigin[4], Sine(DegToRad(EAng[4])) * 50);
		LOrigin[8] = COrigin[8];
		int var1 = CAng[4];
		var1 = FloatAdd(180, var1);
		TeleportEntity(ladderProp, LOrigin, CAng, NULL_VECTOR);
		SetOwner(client, ladderProp);
		if (blockMsgs[client][0][0])
		{
		}
		else
		{
			cmMsg(client, "Created ladder.");
		}
	}
	else
	{
		Format(tempString, 255, "You've reached your max prop count(%d).", GetConVarInt(MaxPropsClient));
		cmMsg(client, tempString);
	}
	return Action3;
}

public Action Command_solidity(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_solid <on or off>");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int sEnt;
	char sClassname[256];
	char sInput[256];
	sEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, sEnt) != -1)
	{
		GetCmdArg(1, sInput, 255);
		GetEdictClassname(sEnt, sClassname, 255);
		int var1;
		if (!StrEqual(sClassname, player, false))
		{
			if (StrEqual(sInput, "on", false))
			{
				DispatchKeyValue(sEnt, "solid", "6");
				changeBeam(client, sEnt);
				if (!blockMsgs[client][0][0])
				{
					PerformByClass(client, sEnt, "Turned solidity on");
				}
				return Action3;
			}
			if (StrEqual(sInput, "off", false))
			{
				DispatchKeyValue(sEnt, "solid", "4");
				changeBeam(client, sEnt);
				if (!blockMsgs[client][0][0])
				{
					PerformByClass(client, sEnt, "Turned solidity off");
				}
				return Action3;
			}
			int var2;
			if (!StrEqual(sInput, "on", false))
			{
				cmMsg(client, "Invalid input specified. Use 'on' or 'off'.");
				return Action3;
			}
		}
		else
		{
			cmMsg(client, "You cannot target this entity.");
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_sound(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_sound <sound alias>");
		PrintToConsole(client, "Type 'v_soundlist' or say 'celsounds' for a list of sound aliases.");
		return Action3;
	}
	if (GetConVarInt(MaxCelsClient) > CountCels(client))
	{
		if (SoundTime[client][0][0] <= GetGameTime() - 1)
		{
			char soundAlias[256];
			GetCmdArg(1, soundAlias, 255);
			Handle Sounds;
			char SoundString[256];
			Sounds = CreateKeyValues("Sounds", "", "");
			FileToKeyValues(Sounds, soundPath);
			LoadString(Sounds, "Sounds", soundAlias, "Null", SoundString);
			if (!StrContains(SoundString, "Null", false))
			{
				cmMsg(client, "Sound not found.");
				return Action3;
			}
			PrecacheSound(SoundString, false);
			int soundPropEnt = CreateEntityByName("prop_physics", -1);
			DispatchKeyValue(soundPropEnt, "model", "models/props_junk/popcan01a.mdl");
			DispatchKeyValue(soundPropEnt, "skin", "1");
			DispatchKeyValue(soundPropEnt, "rendercolor", "255 200 0");
			DispatchKeyValue(soundPropEnt, "spawnflags", "264");
			DispatchSpawn(soundPropEnt);
			DispatchKeyValue(soundPropEnt, "classname", "cel_sound");
			HookSingleEntityOutput(soundPropEnt, "OnPlayerUse", EntityOutput129, false);
			soundTime[soundPropEnt] = 0;
			float SoundOrigin[3];
			float COrigin[3];
			float CEyeAngles[3];
			GetClientEyeAngles(client, CEyeAngles);
			GetClientAbsOrigin(client, COrigin);
			SoundOrigin[0] = FloatAdd(COrigin[0], Cosine(DegToRad(CEyeAngles[4])) * 50);
			SoundOrigin[4] = FloatAdd(COrigin[4], Sine(DegToRad(CEyeAngles[4])) * 50);
			SoundOrigin[8] = COrigin[8] + 32;
			TeleportEntity(soundPropEnt, SoundOrigin, NULL_VECTOR, NULL_VECTOR);
			SetOwner(client, soundPropEnt);
			SoundTime[client] = GetGameTime();
			CloseHandle(Sounds);
		}
		else
		{
			tooFast(client);
			int var1 = SoundTime[client];
			var1 = var1[0][0] + 1;
		}
	}
	else
	{
		Format(tempString, 255, "You've reached your max cel count(%d).", GetConVarInt(MaxCelsClient));
		cmMsg(client, tempString);
	}
	return Action3;
}

public Action Command_music(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_music <music alias> <volume level>");
		PrintToConsole(client, "Minimum = 50; Maximum = 100; Default = 75");
		PrintToConsole(client, "Type 'v_musiclist' or say 'celmusic' for a list of music aliases.");
		return Action3;
	}
	if (GetConVarInt(MaxCelsClient) > CountCels(client))
	{
		if (SoundTime[client][0][0] <= GetGameTime() - 1)
		{
			char musicAlias[256];
			char musicVol[16];
			char loop[16];
			GetCmdArg(1, musicAlias, 255);
			GetCmdArg(2, musicVol, 16);
			GetCmdArg(3, loop, 16);
			Handle Sounds;
			char musicString[256];
			Sounds = CreateKeyValues("Sounds", "", "");
			FileToKeyValues(Sounds, soundPath);
			LoadString(Sounds, "Music", musicAlias, "Null", musicString);
			if (!StrContains(musicString, "Null", false))
			{
				cmMsg(client, "Music track not found.");
				return Action3;
			}
			if (!(StringToInt(musicVol, 10) < 50))
			{
				if (StringToInt(musicVol, 10) > 100)
				{
				}
			}
			char breakString[8][128];
			char mBreak[8][128];
			char mSimplified[256];
			char mFinal[16][128];
			int Seconds;
			ExplodeString(musicString, "|", breakString, 2, 128);
			ExplodeString(breakString[4], ":", mBreak, 2, 128);
			Seconds = StringToInt(mBreak[0][mBreak], 10) * 60;
			Seconds = StringToInt(mBreak[4], 10) + Seconds;
			IntToString(Seconds, mFinal[4], 128);
			ImplodeStrings(mFinal, 4, "|", mSimplified, 255);
			PrecacheSound(breakString[0][breakString], false);
			int musicPropEnt = CreateEntityByName("prop_physics", -1);
			DispatchKeyValue(musicPropEnt, "model", "models/props_lab/citizenradio.mdl");
			DispatchKeyValue(musicPropEnt, "rendercolor", "128 255 0");
			DispatchKeyValue(musicPropEnt, "spawnflags", "264");
			DispatchSpawn(musicPropEnt);
			DispatchKeyValue(musicPropEnt, "classname", "cel_music");
			HookSingleEntityOutput(musicPropEnt, "OnPlayerUse", EntityOutput127, false);
			musicTime[musicPropEnt] = 0;
			float MOrigin[3];
			float COrigin[3];
			float CEyeAngles[3];
			GetClientEyeAngles(client, CEyeAngles);
			GetClientAbsOrigin(client, COrigin);
			MOrigin[0] = FloatAdd(COrigin[0], Cosine(DegToRad(CEyeAngles[4])) * 50);
			MOrigin[4] = FloatAdd(COrigin[4], Sine(DegToRad(CEyeAngles[4])) * 50);
			MOrigin[8] = COrigin[8] + 32;
			TeleportEntity(musicPropEnt, MOrigin, NULL_VECTOR, NULL_VECTOR);
			SetOwner(client, musicPropEnt);
			SoundTime[client] = GetGameTime();
			CloseHandle(Sounds);
		}
		else
		{
			tooFast(client);
			int var1 = SoundTime[client];
			var1 = var1[0][0] + 1;
		}
	}
	else
	{
		Format(tempString, 255, "You've reached your max cel count(%d).", GetConVarInt(MaxCelsClient));
		cmMsg(client, tempString);
	}
	return Action3;
}

public Action Command_startCopy(int client, int Args)
{
	if (copyGrab[client][0][0])
	{
		cmMsg(client, "You are already copying something.");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int cpEnt;
	char cpClass[32];
	cpEnt = GetClientAimTarget(client, false);
	GetEdictClassname(cpEnt, cpClass, 32);
	if (!StrContains(cpClass, "prop_physics", false))
	{
		char modelName[128];
		int renderFx;
		float angRot[3];
		float entOrgn[3];
		int skinNum;
		int entFlags;
		GetEntPropString(cpEnt, PropType1, "m_ModelName", modelName, 128);
		int coloroffset = GetEntSendPropOffs(cpEnt, "m_clrRender", false);
		copyEntColor[client][0][0][0] = GetEntData(cpEnt, coloroffset, 1);
		copyEntColor[client][0][0][4] = GetEntData(cpEnt, coloroffset + 1, 1);
		copyEntColor[client][0][0][8] = GetEntData(cpEnt, coloroffset + 2, 1);
		copyEntColor[client][0][0][12] = GetEntData(cpEnt, coloroffset + 3, 1);
		renderFx = GetEntProp(cpEnt, PropType0, "m_nRenderFX", 1);
		GetEntPropVector(cpEnt, PropType1, "m_vecAbsOrigin", entOrgn);
		GetEntPropVector(cpEnt, PropType1, "m_angRotation", angRot);
		skinNum = GetEntProp(cpEnt, PropType1, "m_nSkin", 1);
		entFlags = GetEntProp(cpEnt, PropType1, "m_spawnflags", 1);
		copyMovetype[client] = GetEntityMoveType(cpEnt);
		if (GetEntityMoveType(cpEnt))
		{
			copyFrozen[client] = 0;
		}
		else
		{
			copyFrozen[client] = 1;
		}
		char SrenderFx[32];
		char SskinNum[32];
		char SentFlags[32];
		IntToString(renderFx, SrenderFx, 32);
		IntToString(skinNum, SskinNum, 32);
		IntToString(entFlags, SentFlags, 32);
		int newEnt;
		if (StrEqual(cpClass, "prop_physics_breakable", false))
		{
			newEnt = CreateEntityByName("prop_physics", -1);
		}
		else
		{
			if (StrEqual(cpClass, "prop_physics_m_breakable", false))
			{
				newEnt = CreateEntityByName("prop_physics_multiplayer", -1);
			}
			newEnt = CreateEntityByName(cpClass, -1);
		}
		if (GetConVarInt(MaxPropsClient) <= CountProps(client))
		{
			Format(tempString, 255, "You've reached your max prop count(%d).", GetConVarInt(MaxPropsClient));
			cmMsg(client, tempString);
			AcceptEntityInput(newEnt, "Kill", -1, -1, 0);
			return Action3;
		}
		DispatchKeyValue(newEnt, "model", modelName);
		DispatchKeyValue(newEnt, "skin", SskinNum);
		DispatchKeyValue(newEnt, "renderfx", SrenderFx);
		DispatchKeyValue(newEnt, "rendermode", "1");
		DispatchKeyValue(newEnt, "spawnflags", SentFlags);
		if (!DispatchSpawn(newEnt))
		{
			if (StrEqual(cpClass, "prop_physics", false))
			{
				newEnt = CreateEntityByName("prop_physics_override", -1);
				DispatchKeyValue(newEnt, "model", modelName);
				DispatchKeyValue(newEnt, "skin", SskinNum);
				DispatchKeyValue(newEnt, "renderfx", SrenderFx);
				DispatchKeyValue(newEnt, "rendermode", "1");
				DispatchKeyValue(newEnt, "spawnflags", SentFlags);
			}
			cmMsg(client, "Error pasting prop.");
			return Action3;
		}
		DispatchSpawn(newEnt);
		if (GetEntProp(newEnt, PropType1, "m_takedamage", 4) == 2)
		{
			if (GetConVarInt(MaxBreakablesClient) <= CountBreakables(client))
			{
				Format(tempString, 255, "You've reached your max breakable prop count(%d).", GetConVarInt(MaxBreakablesClient));
				cmMsg(client, tempString);
				AcceptEntityInput(newEnt, "Kill", -1, -1, 0);
				return Action3;
			}
			if (StrEqual(cpClass, "prop_physics", false))
			{
				DispatchKeyValue(newEnt, "classname", "prop_physics_breakable");
			}
			DispatchKeyValue(newEnt, "classname", "prop_physics_m_breakable");
		}
		SetEntityMoveType(newEnt, MoveType0);
		AcceptEntityInput(newEnt, "disablemotion", -1, -1, 0);
		SetEntityRenderColor(newEnt, 40, 40, 255, 128);
		TeleportEntity(newEnt, entOrgn, angRot, EntAng);
		float COrigin[3];
		GetClientAbsOrigin(client, COrigin);
		copyDist[client][0][0][0] = FloatSub(COrigin[0], entOrgn[0]);
		copyDist[client][0][0][4] = FloatSub(COrigin[4], entOrgn[4]);
		copyDist[client][0][0][8] = FloatSub(COrigin[8], entOrgn[8]);
		SetOwner(client, newEnt);
		copyEnt[client] = newEnt;
		copyGrab[client] = CreateTimer(0.1, copyAction, client, 1);
	}
	else
	{
		cmMsg(client, "You cannot copy this entity.");
	}
	return Action3;
}

public Action copyAction(Handle timer, any client)
{
	if (IsValidEdict(copyEnt[client][0][0]))
	{
		float cOrgn[3];
		float eOrgn[3];
		GetClientAbsOrigin(client, cOrgn);
		eOrgn[0] = FloatSub(cOrgn[0], copyDist[client][0][0][0]);
		eOrgn[4] = FloatSub(cOrgn[4], copyDist[client][0][0][4]);
		eOrgn[8] = FloatSub(cOrgn[8], copyDist[client][0][0][8]);
		TeleportEntity(copyEnt[client][0][0], eOrgn, NULL_VECTOR, EntAng);
	}
	else
	{
		copyEnt[client] = -1;
		KillTimer(copyGrab[client][0][0], false);
		copyGrab[client] = 0;
	}
	return Action0;
}

public Action Command_stopCopy(int client, int args)
{
	int var1;
	if (copyGrab[client][0][0])
	{
		if (!copyFrozen[client][0][0])
		{
			SetEntityMoveType(copyEnt[client][0][0], copyMovetype[client][0][0]);
			AcceptEntityInput(copyEnt[client][0][0], "EnableMotion", -1, -1, 0);
		}
		SetEntityRenderColor(copyEnt[client][0][0], copyEntColor[client][0][0][0], copyEntColor[client][0][0][4], copyEntColor[client][0][0][8], copyEntColor[client][0][0][12]);
		KillTimer(copyGrab[client][0][0], false);
		copyGrab[client] = 0;
	}
	return Action3;
}

public Action Command_alpha(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_amt <transparency>");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int amtEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, amtEnt) != -1)
	{
		char amtClass[32];
		GetEdictClassname(amtEnt, amtClass, 32);
		if (!StrEqual(amtClass, "player", false))
		{
			char amt[32];
			int red;
			int green;
			int blue;
			GetCmdArg(1, amt, 32);
			SetEntProp(amtEnt, PropType1, "m_nRenderMode", any1, 1);
			int coloroffset = GetEntSendPropOffs(amtEnt, "m_clrRender", false);
			red = GetEntData(amtEnt, coloroffset, 1);
			green = GetEntData(amtEnt, coloroffset + 1, 1);
			blue = GetEntData(amtEnt, coloroffset + 2, 1);
			int amtNum;
			int var1;
			if (StringToInt(amt, 10) < 50)
			{
				amtNum = 255;
			}
			else
			{
				amtNum = StringToInt(amt, 10);
			}
			SetEntityRenderColor(amtEnt, red, green, blue, amtNum);
			changeBeam(client, amtEnt);
			Format(tempString, 255, "Set alpha transparency to %d.", amtNum);
			cmMsg(client, tempString);
		}
		else
		{
			cmMsg(client, "Cannot target this entity");
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_rotate(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_rotate <x> <y> <z> <set?>");
		PrintToConsole(client, " - Typing 'set' after the rotation will set the angles instead of adding to it.");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	int rotEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, rotEnt) != -1)
	{
		char rotClass[32];
		GetEdictClassname(rotEnt, rotClass, 32);
		int var1;
		if (!StrEqual(rotClass, "player", false))
		{
			char rotX[16];
			char rotY[16];
			char rotZ[16];
			char rotSet[16];
			GetCmdArg(1, rotX, 16);
			GetCmdArg(2, rotY, 16);
			GetCmdArg(3, rotZ, 16);
			if (args > 3)
			{
				GetCmdArg(4, rotSet, 16);
			}
			float finalAng[3];
			if (StrEqual(rotSet, "set", false))
			{
				finalAng[0] = StringToFloat(rotX);
				finalAng[4] = StringToFloat(rotY);
				finalAng[8] = StringToFloat(rotZ);
			}
			else
			{
				float rotAng[3];
				GetEntPropVector(rotEnt, PropType1, "m_angRotation", rotAng);
				finalAng[0] = FloatAdd(rotAng[0], StringToFloat(rotX));
				finalAng[4] = FloatAdd(rotAng[4], StringToFloat(rotY));
				finalAng[8] = FloatAdd(rotAng[8], StringToFloat(rotZ));
			}
			char netClass[32];
			GetEntityNetClass(rotEnt, netClass, 32);
			if (StrEqual(netClass, "CBasePropDoor", false))
			{
				char mName[128];
				char doorhard[16];
				char doorskin[16];
				int doorColor[4];
				GetEntPropString(rotEnt, PropType1, "m_ModelName", mName, 128);
				int doorSkin = GetEntProp(rotEnt, PropType1, "m_nSkin", 4);
				int doorHardware = GetEntProp(rotEnt, PropType1, "m_nHardwareType", 4);
				int coloroffset = GetEntSendPropOffs(rotEnt, "m_clrRender", false);
				doorColor[0] = GetEntData(rotEnt, coloroffset, 1);
				doorColor[4] = GetEntData(rotEnt, coloroffset + 1, 1);
				doorColor[8] = GetEntData(rotEnt, coloroffset + 2, 1);
				doorColor[12] = GetEntData(rotEnt, coloroffset + 3, 1);
				IntToString(doorSkin, doorskin, 16);
				IntToString(doorHardware, doorhard, 16);
				int dEnt = CreateEntityByName("prop_door_rotating", -1);
				DispatchKeyValue(dEnt, "model", mName);
				DispatchKeyValue(dEnt, "skin", doorskin);
				DispatchKeyValue(dEnt, "distance", "90");
				DispatchKeyValue(dEnt, "speed", "100");
				DispatchKeyValueVector(dEnt, "angles", finalAng);
				DispatchKeyValue(dEnt, "returndelay", "-1");
				DispatchKeyValue(dEnt, "dmg", "20");
				DispatchKeyValue(dEnt, "opendir", "0");
				DispatchKeyValue(dEnt, "hardware", doorhard);
				DispatchKeyValue(dEnt, "spawnflags", "8192");
				DispatchKeyValue(dEnt, "OnFullyOpen", "!caller,close,,3,-1");
				DispatchSpawn(dEnt);
				SetEntProp(dEnt, PropType1, "m_nRenderMode", any1, 1);
				SetEntityRenderColor(dEnt, doorColor[0], doorColor[4], doorColor[8], doorColor[12]);
				float doorOrgn[3];
				GetEntPropVector(rotEnt, PropType1, "m_vecAbsOrigin", doorOrgn);
				RemoveEdict(rotEnt);
				TeleportEntity(dEnt, doorOrgn, NULL_VECTOR, NULL_VECTOR);
			}
			else
			{
				TeleportEntity(rotEnt, NULL_VECTOR, finalAng, NULL_VECTOR);
			}
		}
		else
		{
			cmMsg(client, "Cannot target this entity");
		}
	}
	else
	{
		notYours(client);
	}
	return Action3;
}

public Action Command_giveOwner(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_give <player name>");
		PrintToConsole(client, " - Gives the player the entity you're looking at.");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	char classname[32];
	int giveEnt = GetClientAimTarget(client, false);
	GetEdictClassname(giveEnt, classname, 32);
	int var1;
	if (StrEqual(classname, player, false))
	{
		cmMsg(client, "Cannot target this entity.");
		return Action3;
	}
	char newName[32];
	char nameBuf[32];
	int MaxPlayers;
	int newOwner = -1;
	GetCmdArg(1, newName, 32);
	MaxPlayers = GetMaxClients();
	int C = 1;
	while (C <= MaxPlayers)
	{
		int var2;
		if (IsClientConnected(C))
		{
			GetClientName(C, nameBuf, 32);
			if (StrContains(nameBuf, newName, false) != -1)
			{
				newOwner = C;
				C++;
			}
			C++;
		}
		C++;
	}
	if (newOwner != -1)
	{
		SetOwner(newOwner, giveEnt);
		char brokeClass[8][32];
		char classMsg[256];
		char ownerName[32];
		GetClientName(newOwner, ownerName, 32);
		if (StrContains(classname, "_", false) == -1)
		{
			Format(classMsg, 255, "Gave %s to \x04%s\x01.", classname, ownerName);
		}
		else
		{
			ExplodeString(classname, "_", brokeClass, 2, 32);
			if (StrEqual(brokeClass[0][brokeClass], "combine", false))
			{
				Format(classMsg, 255, "Gave %s %s to \x04%s\x01.", brokeClass[0][brokeClass], brokeClass[4], ownerName);
			}
			Format(classMsg, 255, "Gave %s %s to \x04%s\x01.", brokeClass[4], brokeClass[0][brokeClass], ownerName);
		}
		cmMsg(client, classMsg);
	}
	else
	{
		cmMsg(client, "Unable to find player.");
	}
	return Action3;
}

public Action Command_autoStack(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_autobuild <amount> <X offset> <Y offset> <Z offset>");
		PrintToConsole(client, "Ex. v_autobuild 10 0 0 50");
		return Action3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action3;
	}
	char copyNum[16];
	char xAxis[16];
	char yAxis[16];
	char zAxis[16];
	int rlAmount;
	float offsets[3];
	GetCmdArg(1, copyNum, 16);
	GetCmdArg(2, xAxis, 16);
	GetCmdArg(3, yAxis, 16);
	GetCmdArg(4, zAxis, 16);
	rlAmount = StringToInt(copyNum, 10);
	offsets[0] = StringToFloat(xAxis);
	offsets[4] = StringToFloat(yAxis);
	offsets[8] = StringToFloat(zAxis);
	int var1;
	if (rlAmount < 1)
	{
		cmMsg(client, "Invalid prop amount specified.");
		return Action3;
	}
	int stackEnt;
	char sClass[32];
	stackEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, stackEnt) == -1)
	{
		notYours(client);
		return Action3;
	}
	GetEdictClassname(stackEnt, sClass, 32);
	if (StrContains(sClass, "prop_physics", false))
	{
		cmMsg(client, "You cannot autobuild this entity.");
	}
	else
	{
		char modelName[128];
		int renderFx;
		float angRot[3];
		float entOrgn[3];
		int skinNum;
		int entFlags;
		int eColor[4];
		int takedamage;
		GetEntPropString(stackEnt, PropType1, "m_ModelName", modelName, 128);
		int coloroffset = GetEntSendPropOffs(stackEnt, "m_clrRender", false);
		eColor[0] = GetEntData(stackEnt, coloroffset, 1);
		eColor[4] = GetEntData(stackEnt, coloroffset + 1, 1);
		eColor[8] = GetEntData(stackEnt, coloroffset + 2, 1);
		eColor[12] = GetEntData(stackEnt, coloroffset + 3, 1);
		renderFx = GetEntProp(stackEnt, PropType0, "m_nRenderFX", 1);
		GetEntPropVector(stackEnt, PropType1, "m_vecAbsOrigin", entOrgn);
		GetEntPropVector(stackEnt, PropType1, "m_angRotation", angRot);
		skinNum = GetEntProp(stackEnt, PropType1, "m_nSkin", 1);
		entFlags = GetEntProp(stackEnt, PropType1, "m_spawnflags", 1);
		takedamage = GetEntProp(stackEnt, PropType1, "m_takedamage", 1);
		char SrenderFx[32];
		char SskinNum[32];
		char SentFlags[32];
		IntToString(renderFx, SrenderFx, 32);
		IntToString(skinNum, SskinNum, 32);
		IntToString(entFlags, SentFlags, 32);
		if (GetConVarInt(MaxPropsClient) <= rlAmount + -1 + CountProps(client))
		{
			Format(tempString, 255, "You've reached your max prop count(%d).", GetConVarInt(MaxPropsClient));
			cmMsg(client, tempString);
			return Action3;
		}
		int var2;
		if (GetEntProp(stackEnt, PropType1, "m_takedamage", 4) == 2)
		{
			if (GetConVarInt(MaxBreakablesClient) <= rlAmount + -1 + CountBreakables(client))
			{
				Format(tempString, 255, "You've reached your max breakable prop count(%d).", GetConVarInt(MaxBreakablesClient));
				cmMsg(client, tempString);
				return Action3;
			}
		}
		float originOffset[3];
		bool firstMade;
		int sAmount = 0;
		firstMade = 0;
		int copies = 1;
		while (copies <= 3000)
		{
			if (sAmount >= rlAmount)
			{
				Format(tempString, 255, "Created %d copies of", sAmount);
				PerformByClass(client, stackEnt, tempString);
				return Action3;
			}
			if (StrEqual(sClass, "prop_physics_breakable", false))
			{
				copies = CreateEntityByName("prop_physics", -1);
			}
			else
			{
				if (StrEqual(sClass, "prop_physics_m_breakable", false))
				{
					copies = CreateEntityByName("prop_physics_multiplayer", -1);
				}
				copies = CreateEntityByName(sClass, -1);
			}
			DispatchKeyValue(copies, "model", modelName);
			DispatchKeyValue(copies, "skin", SskinNum);
			DispatchKeyValue(copies, "renderfx", SrenderFx);
			DispatchKeyValue(copies, "rendermode", "1");
			DispatchKeyValue(copies, "spawnflags", SentFlags);
			SetEntProp(copies, PropType1, "m_takedamage", takedamage, 1);
			if (!DispatchSpawn(copies))
			{
				AcceptEntityInput(copies, "Kill", -1, -1, 0);
				if (StrEqual(sClass, "prop_physics", false))
				{
					copies = CreateEntityByName("prop_physics_override", -1);
					DispatchKeyValue(copies, "model", modelName);
					DispatchKeyValue(copies, "skin", SskinNum);
					DispatchKeyValue(copies, "renderfx", SrenderFx);
					DispatchKeyValue(copies, "rendermode", "1");
					DispatchKeyValue(copies, "spawnflags", SentFlags);
				}
				cmMsg(client, "Error pasting prop.");
				return Action3;
			}
			DispatchSpawn(copies);
			SetEntProp(copies, PropType1, "m_takedamage", takedamage, 1);
			SetEntityRenderColor(copies, eColor[0], eColor[4], eColor[8], eColor[12]);
			if (GetEntProp(copies, PropType1, "m_takedamage", 4) == 2)
			{
				if (StrEqual(sClass, "prop_physics", false))
				{
					DispatchKeyValue(copies, "classname", "prop_physics_breakable");
				}
				DispatchKeyValue(copies, "classname", "prop_physics_m_breakable");
			}
			SetEntityMoveType(copies, MoveType0);
			AcceptEntityInput(copies, "disablemotion", -1, -1, 0);
			if (!firstMade)
			{
				originOffset[0] = FloatAdd(entOrgn[0], offsets[0]);
				originOffset[4] = FloatAdd(entOrgn[4], offsets[4]);
				originOffset[8] = FloatAdd(entOrgn[8], offsets[8]);
				firstMade = 1;
			}
			else
			{
				originOffset[0] = FloatAdd(originOffset[0], offsets[0]);
				int var3 = originOffset[4];
				var3 = FloatAdd(var3, offsets[4]);
				int var4 = originOffset[8];
				var4 = FloatAdd(var4, offsets[8]);
			}
			TeleportEntity(copies, originOffset, angRot, EntAng);
			SetOwner(client, copies);
			sAmount += 1;
			copies++;
		}
	}
	return Action3;
}

public Action Command_propCount(int client, int args)
{
	int ME;
	int allE;
	int pCount;
	int bCount;
	int nCount;
	int vCount;
	int cCount;
	pCount = 0;
	bCount = 0;
	nCount = 0;
	vCount = 0;
	cCount = 0;
	ME = GetMaxEntities();
	if (args < 1)
	{
		allE = 0;
		while (allE <= ME)
		{
			int var1;
			if (IsValidEdict(allE))
			{
				if (FindOwner(client, allE) == 1)
				{
					char eClass[32];
					GetEdictClassname(allE, eClass, 32);
					if (StrContains(eClass, "prop_", false))
					{
						if (StrContains(eClass, "npc_", false))
						{
							int var2;
							if (StrEqual(eClass, "prop_vehicle_airboat", false))
							{
								vCount += 1;
								allE++;
							}
							if (StrContains(eClass, "cel", false))
							{
								allE++;
							}
							else
							{
								cCount += 1;
								allE++;
							}
							allE++;
						}
						nCount += 1;
						allE++;
					}
					else
					{
						pCount += 1;
						if (StrContains(eClass, "breakable", false) != -1)
						{
							bCount += 1;
							allE++;
						}
						allE++;
					}
					allE++;
				}
				allE++;
			}
			allE++;
		}
		PrintToChat(client, "\x04|CelMod|\x01 Props: %d", pCount);
		PrintToChat(client, "\x04|CelMod|\x01 Breakables: %d", bCount);
		PrintToChat(client, "\x04|CelMod|\x01 NPCs: %d", nCount);
		PrintToChat(client, "\x04|CelMod|\x01 Vehicles: %d", vCount);
		PrintToChat(client, "\x04|CelMod|\x01 Cels: %d", cCount);
		return Action3;
	}
	char findFilter[256];
	GetCmdArg(1, findFilter, 255);
	allE = 0;
	while (allE <= ME)
	{
		int var3;
		if (IsValidEdict(allE))
		{
			if (FindOwner(client, allE) == 1)
			{
				char fClass[32];
				GetEdictClassname(allE, fClass, 32);
				if (StrContains(fClass, "prop_", false))
				{
					if (StrContains(fClass, "npc_", false))
					{
						int var4;
						if (StrEqual(fClass, "prop_vehicle_airboat", false))
						{
							vCount += 1;
							allE++;
						}
						if (StrContains(fClass, "cel", false))
						{
							allE++;
						}
						else
						{
							cCount += 1;
							allE++;
						}
						allE++;
					}
					nCount += 1;
					allE++;
				}
				else
				{
					pCount += 1;
					if (StrContains(fClass, "breakable", false) != -1)
					{
						bCount += 1;
						allE++;
					}
					allE++;
				}
				allE++;
			}
			allE++;
		}
		allE++;
	}
	if (StrEqual(findFilter, "props", false))
	{
		PrintToChat(client, "\x04|CelMod|\x01 Props: %d", pCount);
	}
	else
	{
		if (StrEqual(findFilter, "breakables", false))
		{
			PrintToChat(client, "\x04|CelMod|\x01 Breakables: %d", bCount);
		}
		if (StrEqual(findFilter, "npcs", false))
		{
			PrintToChat(client, "\x04|CelMod|\x01 NPCs: %d", nCount);
		}
		if (StrEqual(findFilter, "vehicles", false))
		{
			PrintToChat(client, "\x04|CelMod|\x01 Vehicles: %d", vCount);
		}
		if (StrEqual(findFilter, "cels", false))
		{
			PrintToChat(client, "\x04|CelMod|\x01 Cels: %d", cCount);
		}
	}
	return Action3;
}

public Action Command_vehicleStart(int client, int args)
{
	int playerEnt = GetEntPropEnt(client, PropType1, "m_hVehicle");
	int var1;
	if (playerEnt != -1)
	{
		vehicleTimer[client] = CreateTimer(0.1, moveVehicle, client, 1);
	}
	return Action3;
}

public Action moveVehicle(Handle timer, any client)
{
	int playerEnt = GetEntPropEnt(client, PropType1, "m_hVehicle");
	if (playerEnt != -1)
	{
		float vehAng[3];
		float vehVelocity[3];
		GetClientEyeAngles(client, vehAng);
		vehVelocity[0] = Cosine(DegToRad(vehAng[4])) * 700;
		vehVelocity[4] = Sine(DegToRad(vehAng[4])) * 700;
		vehVelocity[8] = Sine(DegToRad(vehAng[0])) * -1680;
		TeleportEntity(playerEnt, NULL_VECTOR, NULL_VECTOR, vehVelocity);
	}
	return Action0;
}

public Action Command_vehicleStop(int client, int args)
{
	if (vehicleTimer[client][0][0])
	{
		KillTimer(vehicleTimer[client][0][0], false);
		vehicleTimer[client] = 0;
	}
	return Action3;
}

public Action Command_vehicleStartBack(int client, int args)
{
	int playerEnt = GetEntPropEnt(client, PropType1, "m_hVehicle");
	int var1;
	if (playerEnt != -1)
	{
		vehicleTimer[client] = CreateTimer(0.1, moveVehicleBack, client, 1);
	}
	return Action3;
}

public Action moveVehicleBack(Handle timer, any client)
{
	int playerEnt = GetEntPropEnt(client, PropType1, "m_hVehicle");
	if (playerEnt != -1)
	{
		float vehAng[3];
		float vehVelocity[3];
		GetClientEyeAngles(client, vehAng);
		vehVelocity[0] = Cosine(DegToRad(vehAng[4])) * -700;
		vehVelocity[4] = Sine(DegToRad(vehAng[4])) * -700;
		vehVelocity[8] = Sine(DegToRad(vehAng[0])) * 1680;
		TeleportEntity(playerEnt, NULL_VECTOR, NULL_VECTOR, vehVelocity);
	}
	return Action0;
}


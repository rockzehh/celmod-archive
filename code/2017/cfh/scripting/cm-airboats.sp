#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define VERSION "1.0.0"

#define MAX_AIRBOATS 10

char g_sAirboats[PLATFORM_MAX_PATH];

public Plugin myinfo = 
{
	name = "|CelMod| Airboats", 
	author = "FusionLock", 
	description = "Spawns the little buggers on map spawn according to map.", 
	version = VERSION, 
	url = "https://bitbucket.org/zaachhhh/celmod-cels-fun-house"
};

public void OnMapStart()
{
	BuildPath(Path_SM, g_sAirboats, sizeof(g_sAirboats), "data/cm-cfh/airboats.txt");
	if (!FileExists(g_sAirboats))
	{
		SetFailState("|CelMod| Couldn't find 'data/cm-cfh/airboats.txt'!");
	}
	
	CelMod_AirboatSpawn();
}

//Plugin Stocks:
public void CelMod_AirboatSpawn()
{
	char sDegrees[6][64], sMap[96], sNumber[64], sTempString[256];
	float fAngles[3], fOrigin[3];
	
	GetCurrentMap(sMap, sizeof(sMap));
	
	KeyValues hAirboats = new KeyValues("Airboats");
	
	if (hAirboats.ImportFromFile(g_sAirboats))
	{
		if (hAirboats.JumpToKey(sMap, false))
		{
			for (int i = 0; i < MAX_AIRBOATS; i++)
			{
				Format(sNumber, sizeof(sNumber), "%i", i);
				
				hAirboats.GetString(sNumber, sTempString, sizeof(sTempString), "null");
				
				if (StrEqual(sTempString, "null")){} else {
					ExplodeString(sTempString, " ", sDegrees, 6, sizeof(sDegrees[]));
					
					fAngles[0] = StringToFloat(sDegrees[0]);
					fAngles[1] = StringToFloat(sDegrees[1]);
					fAngles[2] = StringToFloat(sDegrees[2]);
					
					fOrigin[0] = StringToFloat(sDegrees[3]);
					fOrigin[1] = StringToFloat(sDegrees[4]);
					fOrigin[2] = StringToFloat(sDegrees[5]);
					
					CelMod_PreformAirboatSpawn(i, fAngles, fOrigin);
				}
			}
		} else {
			PrintToServer("|CelMod| Cannot find map.");
		}
	} else {
		SetFailState("|CelMod| Couldn't find 'data/cm-cfh/airboats.txt'!");
	}
	
	hAirboats.Close();
}

public void CelMod_PreformAirboatSpawn(const int iNumber, const float fAngles[3], const float fOrigin[3])
{
	int iAirboat = CreateEntityByName("prop_vehicle_airboat");
	
	PrecacheModel("models/airboat.mdl");
	
	DispatchKeyValue(iAirboat, "classname", "prop_vehicle_airboat");
	DispatchKeyValue(iAirboat, "globalname", "cel_airboat");
	DispatchKeyValue(iAirboat, "model", "models/airboat.mdl");
	DispatchKeyValue(iAirboat, "targetname", "cel_airboat");
	DispatchKeyValue(iAirboat, "vehiclescript", "scripts/vehicles/airboat.txt");
	
	DispatchSpawn(iAirboat);
	
	ActivateEntity(iAirboat);
	
	TeleportEntity(iAirboat, fOrigin, fAngles, NULL_VECTOR);
	
	SetEntityRenderColor(iAirboat, 255, 255, 255, 255);
	SetEntityRenderMode(iAirboat, RENDER_TRANSALPHA);
	
	PrintToServer("|CelMod| Spawned Airboat #%i", iNumber);
}

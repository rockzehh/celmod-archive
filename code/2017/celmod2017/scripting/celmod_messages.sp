#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "FusionLock"
#define PLUGIN_VERSION "1.01.1"

#include <sourcemod>
#include <morecolors>

#pragma newdecls required

char g_sMessageDB[PLATFORM_MAX_PATH];

Handle g_hAnnouncementTimer;
Handle g_hUpdateTimer;

int g_iAnnouncementNumber = 0;

public Plugin myinfo = 
{
	name = "|CelMod| - Messages",
	author = PLUGIN_AUTHOR,
	description = "Announcements/Update notifications.",
	version = PLUGIN_VERSION,
	url = "http://xfusionlockx.tk/celmod"
};

public void OnPluginStart()
{
	BuildPath(Path_SM, g_sMessageDB, sizeof(g_sMessageDB), "data/celmod/messages.txt");
	
	g_iAnnouncementNumber = 0;
}

public void OnMapStart()
{
	g_hAnnouncementTimer = CreateTimer(60.0, Timer_Announce, _, TIMER_REPEAT);
	g_hUpdateTimer = CreateTimer(540.0, Timer_Update, _, TIMER_REPEAT);
}

public void OnMapEnd()
{
	CloseHandle(g_hAnnouncementTimer);
	CloseHandle(g_hUpdateTimer);
}

public Action Timer_Announce(Handle hTimer)
{
	char sAnnouncement[512];
	
	KeyValues hAnnounce = CreateKeyValues("Vault");
	
	FileToKeyValues(hAnnounce, g_sMessageDB);
	
	KvJumpToKey(hAnnounce, "Announcements", false);
	
	switch(g_iAnnouncementNumber)
	{
		case 0:
		{
			KvGetString(hAnnounce, "0", sAnnouncement, sizeof(sAnnouncement));
			g_iAnnouncementNumber = 1;
		}
		case 1:
		{
			KvGetString(hAnnounce, "1", sAnnouncement, sizeof(sAnnouncement));
			g_iAnnouncementNumber = 2;
		}
		case 2:
		{
			KvGetString(hAnnounce, "2", sAnnouncement, sizeof(sAnnouncement));
			g_iAnnouncementNumber = 3;
		}
		case 3:
		{
			KvGetString(hAnnounce, "3", sAnnouncement, sizeof(sAnnouncement));
			g_iAnnouncementNumber = 4;
		}
		case 4:
		{
			KvGetString(hAnnounce, "4", sAnnouncement, sizeof(sAnnouncement));
			g_iAnnouncementNumber = 5;
		}
		case 5:
		{
			KvGetString(hAnnounce, "5", sAnnouncement, sizeof(sAnnouncement));
			g_iAnnouncementNumber = 6;
		}
		case 6:
		{
			KvGetString(hAnnounce, "6", sAnnouncement, sizeof(sAnnouncement));
			g_iAnnouncementNumber = 0;
		}
	}
	
	CloseHandle(hAnnounce);
	
	CPrintToChatAll("{blue}|CM|{default} %s", sAnnouncement);
}

public Action Timer_Update(Handle hTimer)
{
	char sUpdate[2][512];
	
	KeyValues hUpdate = CreateKeyValues("Vault");
	
	FileToKeyValues(hUpdate, g_sMessageDB);
	
	KvJumpToKey(hUpdate, "Update", false);
	
	KvGetString(hUpdate, "firstline", sUpdate[0], sizeof(sUpdate));
	KvGetString(hUpdate, "extraline", sUpdate[1], sizeof(sUpdate));
	
	CloseHandle(hUpdate);
	
	if(StrEqual(sUpdate[1], ""))
	{
		CPrintToChatAll("{blue}|CM|{default} {green}Latest Update{default}: %s", sUpdate[0]);
	}else{
		CPrintToChatAll("{blue}|CM|{default} {green}Latest Update{default}: %s", sUpdate[0]);
		CPrintToChatAll("- %s", sUpdate[1]);
	}
}

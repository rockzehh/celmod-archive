#include <morecolors>

/**
 * Prints a CelMod message to a client.
 *
 * @param iClient	Client Index.
 * @param sMessage	Message (+ Formatting Rules).
 *
 */
public void CelMod_PrintToChat(int iClient, const char[] sMessage, any...)
{
	char sBuffer[MAX_MESSAGE_LENGTH], sBuffer2[MAX_MESSAGE_LENGTH];
	
	SetGlobalTransTarget(iClient);
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 3);
	
	CPrintToChat(iClient, "{blue}|CelMod|{default} %s", sBuffer2);
	
	if(IsClientInGame(iClient))
	{
		switch(GetRandomInt(0, 1))
		{
			case 0:
			{
				ClientCommand(iClient, "play npc/stalker/stalker_footstep_left1");
			}
			
			case 1:
			{
				ClientCommand(iClient, "play npc/stalker/stalker_footstep_right1");
			}
			
			default:
			{
			}
		}
	}
}

/**
 * Prints a CelMod message to all clients.
 *
 * @param sMessage	Message (+ Formatting Rules).
 *
 */
public void CelMod_PrintToChatAll(const char[] sMessage, any...)
{
	char sBuffer[MAX_MESSAGE_LENGTH], sBuffer2[MAX_MESSAGE_LENGTH];
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 2);
	
	CPrintToChatAll("{blue}|CM|{default} %s", sBuffer2);
}

/**
 * Replies with a CelMod message to a client.
 *
 * @param iClient	Client Index.
 * @param sMessage	Message (+ Formatting Rules).
 *
 */
public void CelMod_ReplyToCommand(int iClient, const char[] sMessage, any...)
{
	char sBuffer[MAX_MESSAGE_LENGTH], sBuffer2[MAX_MESSAGE_LENGTH];
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 3);
	
	ReplaceString(sBuffer2, sizeof(sBuffer2), "[cm]", GetCmdReplySource() == SM_REPLY_TO_CHAT ? "!" : "sm_");
	
	if (GetCmdReplySource() == SM_REPLY_TO_CHAT)
	{
		CelMod_PrintToChat(iClient, sBuffer2);
	} else {
		CRemoveTags(sBuffer2, sizeof(sBuffer2));
		
		PrintToConsole(iClient, "|CelMod| %s", sBuffer2);
	}
}
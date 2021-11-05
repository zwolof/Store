void eStore_OnPluginStart() {
    
    
    if(g_dataOrigin == DataOrigin_API) {
        httpClient = new HTTPClient(API_ENDPOINT);
    }

    if(g_dataOrigin == DataOrigin_DB) {
        Database.Connect(SQL_ConnectCallback, "estore");
    }

    // ArrayLists
    g_alCategories = new ArrayList(sizeof(Category));
    g_alItems = new ArrayList(sizeof(Item));
    g_alMarketplace = new ArrayList(sizeof(MarketItem));
    g_alBoxes = new ArrayList(sizeof(Box));

    // API
    if(g_dataOrigin == DataOrigin_API) {
        API_GetAllCategories();
        API_GetAllItems();
    }

    // Events
    HookEvent("round_start", eStore_OnRoundStart, EventHookMode_Post);

    // Chat Listeners
    AddCommandListener(eStore_ChatHook, "say");
    AddCommandListener(eStore_ChatHook, "say_team");
}

public void SQL_ConnectCallback(Database db, const char[] error, any data) {
    if(error[0] != '\0') {
        SetFailState("Database Could not connect: %s", error);
        return;
    }
    g_StoreDatabase = db;

    DB_FetchCategories();
    DB_FetchItems();
}

public Action eStore_ChatHook(int client, const char[] command, int argc) {
    if(g_bIsClientTakingQuiz[client][QT_Math]) {
        char sAnswer[32];
        FormatEx(sAnswer, sizeof(sAnswer), "%d", g_iClientQuizAnswer[client]);
        if(StrEqual(command, sAnswer, false)) {

            int reward = GetRandomInt(10, 40);
            eStore_Print(client, "\x08You answered the question correctly, you got \x04+%d\x08 %s", reward, STORE_CREDITSNAME_LC);
            eStore[client].add(reward);

            return Plugin_Handled;
        }   
    }
    return Plugin_Continue;
}

public void eStore_OnRoundStart(Event event, const char[] sName, bool bDontBroadcast) {
    if(g_alBoxes == null) {
        g_alBoxes = new ArrayList(sizeof(Box));
    }

    int len = g_alBoxes.Length;
    if(len <= 0) return;

    Box box;
    for(int i = 0; i < len; i++) {
        g_alBoxes.GetArray(i, box, sizeof(Box));

        if(IsValidEntity(box.entity_id) && IsValidEdict(box.entity_id)) {
            SDKUnhook(box.entity_id, SDKHook_Touch, eStore_BoxPickedUp);
            AcceptEntityInput(box.entity_id, "kill");
            RemoveEdict(box.entity_id);
        }
    }
    g_alBoxes.Clear();
}

void eStore_OnPluginEnd() {

}

public void OnClientPutInServer(int client) {
    if(eStore_IsValidClient(client)) {
        g_iClientQuizAnswer[client] = -1;
        g_bIsClientTakingQuiz[client][QT_Math] = false;
        g_bIsClientTakingQuiz[client][QT_Facts] = false;
    }
}

public void OnClientPostAdminCheck(int client) {
    if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client)) {

        // Save userId In struct
        eStore[client].userid = GetClientUserId(client);

        // Get Their Inventory Items
        if(g_alInventory[client] == null) {
            g_alInventory[client] = new ArrayList(sizeof(Item));

            if(g_dataOrigin == DataOrigin_API) {
                API_GetInventoryItems(client);
            }

            if(g_dataOrigin == DataOrigin_DB) {
                DB_GetClientInventory(client);
            }
        }
        
        // Get Their Equipped Items
        if(g_alEquipped[client] == null) {
            g_alEquipped[client] = new ArrayList(sizeof(Item));

            if(g_dataOrigin == DataOrigin_API) {
                API_GetEquippedItems(client);
            }

            if(g_dataOrigin == DataOrigin_DB) {
                DB_GetClientEquipped(client);
            }
        }

        // Get Their Lootboxes
        if(g_alClientBoxes[client] == null) { 
            g_alClientBoxes[client] = new ArrayList(sizeof(Box));

            if(g_dataOrigin == DataOrigin_API) {
                API_GetLootboxes(client);
            }

            if(g_dataOrigin == DataOrigin_DB) {
                DB_FetchLootboxes(client);
            }
        }

        // Get users credits
        if(g_dataOrigin == DataOrigin_API) {
            API_GetUserCredits(client);
        }

        if(g_dataOrigin == DataOrigin_DB) {
            DB_GetClientCredits(client);
        }

        // Create a timer to hand out credits
        g_hCreditsTimer[client] = CreateTimer(eUtils_GetSecondsFromMinutes(5), Timer_GiveCredits, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
    }
}

public void OnClientDisconnect(int client) {
    if(eStore_IsValidClient(client)) {

        // Update their credits
        API_UpdateUserCredits(client);

        // Timer handle
        delete g_hCreditsTimer[client];

        // Client Arraylists
        delete g_alInventory[client];
        delete g_alEquipped[client];
        delete g_alClientBoxes[client];
    }
}

public void OnMapEnd() {
    delete g_alBoxes;
    delete g_alMarketplace;
}

public Action Hook_eStoreWeaponDrop(int client, int wpnid)
{
	if(wpnid < 1) return;
    RequestFrame(Hook_SetWorldModel, EntIndexToEntRef(wpnid));
}

public void Hook_SetWorldModel(any data) {
    int wpnid = EntRefToEntIndex(data);

    if(wpnid == INVALID_ENT_REFERENCE || !IsValidEntity(wpnid) || !IsValidEdict(wpnid)) return;
	
	char globalName[64];
    GetEntPropString(wpnid, Prop_Data, "m_iGlobalname", globalName, sizeof(globalName));

    PrintToChatAll("Set worldmodel %d", wpnid);
    //SetEntityModel(wpnid, bit[1]);
}

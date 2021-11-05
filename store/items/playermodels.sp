void eStore_AutoExecute(int client) {
    StringMap map;
}

void eStore_SetPlayerModel(int client, Item item) {
    if(eUtils_IsValidClient(client)) {
        SetEntityModel(client, item.modelpath);
    }   
}

void eStore_ResetPlayerModel(int client) {
    Settings settings;

    char sAgent[PLATFORM_MAX_PATH];
    strcopy(sAgent, sizeof(sAgent), settings.agent);

    SetEntityModel(client, sAgent);
}
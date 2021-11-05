public void eStore_SetCustomKnife(int client, Item item) {
    int precached = eStore_FindPrecachedModelByItemId(item);
    if(precached != -1) {
        FPVMI_AddViewModelToClient(client, "weapon_knife", precached);
    }
}

public void eStore_ResetCustomKnife(int client) {
    FPVMI_RemoveViewModelToClient(client, "weapon_knife");
}
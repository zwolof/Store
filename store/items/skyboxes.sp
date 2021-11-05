public void eStore_SetSkybox(int client, char[] skybox) {
    ConVar cvSkyName = FindConVar("sv_skyname");
	if (StrEqual(skybox, "mapdefault")) {
		//If it's default, get sv_skyname and set it to client
		char buffer[32];
        cvSkyName.GetString(buffer, sizeof(buffer));
        cvSkyName.ReplicateToClient(client, buffer);
        return;
	}
	cvSkyName.ReplicateToClient(client, buffer);
}

public void eStore_ResetSkybox(int client) {
    eStore_SetSkybox(client, "mapdefault");
    return;
}
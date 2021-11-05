enum AnimatedClantagMode {
    ACM_Disabled,
    ACM_Normal,
    ACM_Backwards,
    ACM_Gamesense,
    ACM_Blinking
}

char g_sAnimatedClantag[MAXPLAYERS+1][256];
Handle g_hAnimatedClantagTimer[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
float g_fAnimatedClantagTime[MAXPLAYERS+1] = {1.0, ...};
bool g_bAnimatedClantagActivated[MAXPLAYERS+1] = {false, ...};
int g_iLastIndex[MAXPLAYERS+1];
int g_iAnimationState[MAXPLAYERS+1];

AnimatedClantagMode animationMode[MAXPLAYERS+1] = {ACM_Disabled, ...};

void eStore_SetAnimatedClantag(int client, char[] tag) {
    g_hAnimatedClantagTimer[client] = null;
    delete g_hAnimatedClantagTimer[client];

    strcopy(g_sAnimatedClantag[client], sizeof(g_sAnimatedClantag[]), tag);
    g_iAnimationState[client] = 0;

    g_bAnimatedClantagActivated[client] = true;
    g_hAnimatedClantagTimer[client] = CreateTimer(0.24, eStore_AnimatedClantagTimerHandler, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

void eStore_GetCurrentClantag(int client, char tag, int maxlen) {
    CS_GetClientClanTag(client, tag, maxlen);
}

void eStore_AnimatedClantags_OnSpawn(int client) {

}

void eStore_RemoveAnimatedClantag(int client) {
    g_bAnimatedClantagActivated[client] = false;
    CS_SetClientClanTag(client, "");
}

public Action eStore_AnimatedClantagTimerHandler(Handle timer, any data) {
    int client = GetClientOfUserId(data);
    static bool bGoBackwards = false;

    if(!g_bAnimatedClantagActivated[client]) {
        return Plugin_Stop;
    }

    switch(g_iAnimationState[client]++) {
        case 0: {
            CS_SetClientClanTag(client, "                  ");
        }
        case 1: {
            CS_SetClientClanTag(client, "                 g");
        }
        case 2: {
            CS_SetClientClanTag(client, "                ga");
        }
        case 3: {
            CS_SetClientClanTag(client, "               gam");
        }
        case 4: {
            CS_SetClientClanTag(client, "              game");
        }
        case 5: {
            CS_SetClientClanTag(client, "             games");
        }
        case 6: {
            CS_SetClientClanTag(client, "            gamese");
        }
        case 7: {
            CS_SetClientClanTag(client, "           gamesen");
        }
        case 8: {
            CS_SetClientClanTag(client, "          gamesens");
        }
        case 9: {
            CS_SetClientClanTag(client, "         gamesense");
        }
        case 10: {
            CS_SetClientClanTag(client, "        gamesense ");
        }
        case 11: {
            CS_SetClientClanTag(client, "       gamesense  ");
        }
        case 12: {
            CS_SetClientClanTag(client, "      gamesense   ");
        }
        case 13: {
            CS_SetClientClanTag(client, "     gamesense    ");
        }
        case 14: {
            CS_SetClientClanTag(client, "    gamesense     ");
        }
        case 15: {
            CS_SetClientClanTag(client, "   gamesense      ");
        }
        case 16: {
            CS_SetClientClanTag(client, "  gamesense       ");
        }
        case 17: {
            CS_SetClientClanTag(client, " gamesense        ");
        }
        case 18: {
            CS_SetClientClanTag(client, "gamesense         ");
        }
        case 19: {
            CS_SetClientClanTag(client, "amesense          ");
        }
        case 20: {
            CS_SetClientClanTag(client, "mesense           ");
        }
        case 22: {
            CS_SetClientClanTag(client, "esense            ");
        }
        case 23: {
            CS_SetClientClanTag(client, "sense             ");
        }
        case 24: {
            CS_SetClientClanTag(client, "sens              ");
        }
        case 25: {
            CS_SetClientClanTag(client, "sen               ");
        }
        case 26: {
            CS_SetClientClanTag(client, "se                ");
        }
        case 27: {
            CS_SetClientClanTag(client, "s                 ");
            g_iAnimationState[client] = 0;
        }
    }
    
    
    
//     char buffer[64], sTest[128];
//     // FormatEx(sTest, sizeof(sTest), "poggers");
//     int newIndex = bGoBackwards ? --g_iLastIndex[client] {
//  ++g_iLastIndex[client];

//     strcopy(buffer, newIndex, g_sAnimatedClantag[client]);
    
//     CS_SetClientClanTag(client, buffer);
//     eStore_Print(client, "Tag{
//  \x04%s", buffer);

//     if (g_iLastIndex[client] > strlen(g_sAnimatedClantag[client]) && !bGoBackwards) {
//         // g_iLastIndex[client] = 0;
//         bGoBackwards = true;
//     }

//     if (g_iLastIndex[client] == 0 && bGoBackwards) {
//         g_iLastIndex[client] = 0;
//         bGoBackwards = false;
//     }

    return Plugin_Continue;
}
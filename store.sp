// Base Includes
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <ripext>
#include <fpvm_interface>


// Plugin Info
#define PLUGIN_NAME                     "EFRAG [Store System]"
#define PLUGIN_DESCRIPTION              "Dynamic Store System with a NodeJS Backend"
#define PLUGIN_VERSION                  "1.0.2"
#define PLUGIN_URL                      "www.efrag-community.eu"
#define PLUGIN_AUTHOR                   "zwolof"




// Globals for the plugin
#define PREFIX                          " \x01\x04\x01[\x0F☰  EFRAG\x01] "


// Max Strings & Array Sizes
#define MAX_NAME                        128
#define MAX_DESCRIPTION                 128
#define MAX_FLAGS                       16
#define MAX_SELL_PERCENTAGE             0.7
#define MAX_CATEGORIES                  100


// Store Specific
#define STORE_MENUTITLE                 "efrag.eu | Store"
#define STORE_CREDITS_PER_MINUTE        5


// API Endpoints
#define API_ENDPOINT                    "http://s1.efrag.eu:3010/api/store/"
#define API_AUTHKEY                     "5ae7fdde-8132-43bc-a3a5-1a87322d2163"

// Equipped items, update, put and get
#define API_EQUIPPED_ENDPOINT           "inventory/equipped/%s"
#define API_EQUIPPED_EQUIP_ENDPOINT     "inventory/equip/%s"
#define API_EQUIPPED_UNEQUIP_ENDPOINT   "inventory/unequip/%s"

// Get Inventory, sell and buy items
#define API_INVENTORY_ENDPOINT          "inventory/%s"
#define API_INVENTORY_BUY_ENDPOINT      "inventory/buy/%s"
#define API_INVENTORY_SELL_ENDPOINT     "inventory/sell/%s"

// Used for lootboxes, fetch and update
#define API_BOXES_REMOVE_ENDPOINT       "boxes/remove/%s"
#define API_BOXES_ADD_ENDPOINT          "boxes/add/%s"
#define API_BOXES_FETCH_ENDPOINT        "boxes/get/%s"

// Used to fetch userdata such as credits
#define API_USERS_ENDPOINT              "users/%s"

// Other Endpoints
#define API_MARKETPLACE_ENDPOINT        "marketplace/%s"
#define API_ITEMS_ENDPOINT              "items"
#define API_CATEGORIES_ENDPOINT         "categories"


// Chat & Colors
#define REWARD_COLOR_ITEM               "#e3ad39"
#define REWARD_COLOR_CREDITS            "#40fe40"



// Plugin Information
public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

// Include Modules
#include "store/globals.sp"

// Other
#include "store/forwards.sp"
#include "store/hooks.sp"
#include "store/functions.sp"
#include "store/core.sp"
#include "store/api.sp"
#include "store/database.sp"
#include "store/commandhandlers.sp"
#include "store/timers.sp"
#include "store/boxes.sp"
#include "store/menus.sp"
#include "store/helpers.sp"
// #include "store/playerruncmd.sp"

// Items
#include "store/items/animatedclantags.sp"
// #include "store/items/colors.sp"
// #include "store/items/tags.sp"
// #include "store/items/customknives.sp"
// #include "store/items/grenademodels.sp"
// #include "store/items/hats.sp"
// #include "store/items/playermodels.sp"
// #include "store/items/skyboxes.sp"
// #include "store/items/trails.sp"
// #include "store/items/particletrails.sp"


public void OnMapStart() {
    char sPath[256];
    FormatEx(sPath, sizeof sPath, g_sBoxModels[0]);

    // Main MDL
    AddFileToDownloadsTable(sPath);
    PrecacheModel(sPath);

    // Other file exts
    for(int model = 0; model < sizeof(g_sBoxModels); model++) {
        for(int type = 0; type < sizeof(g_sFileTypes); type++){
			ReplaceString(sPath, sizeof(sPath), g_sFileTypes[type], g_sFileTypes[type+1]);
			AddFileToDownloadsTable(sPath);
		}
    }
    for(int model = 0; model < sizeof(g_sBoxMaterials); model++) {
        FormatEx(sPath, sizeof(sPath), g_sBoxMaterials[model]);
		AddFileToDownloadsTable(sPath);
    }
}
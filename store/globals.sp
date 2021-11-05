enum DataOrigin {
    DataOrigin_API,
    DataOrigin_DB
}

DataOrigin g_dataOrigin = DataOrigin_DB;

Database g_StoreDatabase = null
HTTPClient httpClient = null;

ArrayList g_alCategories = null;
ArrayList g_alItems = null;
ArrayList g_alInventory[MAXPLAYERS+1];
ArrayList g_alEquipped[MAXPLAYERS+1];
ArrayList g_alMarketplace = null;
ArrayList g_alBoxes = null;
ArrayList g_alClientBoxes[MAXPLAYERS+1];
//ArrayList g_alInventory = null;

Handle g_hCreditsTimer[MAXPLAYERS+1] = {null, ...};
Handle g_hOpeningTimer[MAXPLAYERS+1] = {null, ...};

#define BOX_OPENING_ANIM_COUNT 12

ConVar g_SkyName = FindConVar("sv_skyname");

enum QuestionType {
    QT_Facts = 0,
    QT_Math
}

#define STORE_CREDITSNAME_UC "Fragments"
#define STORE_CREDITSNAME_LC "fragments"

bool g_bIsClientTakingQuiz[MAXPLAYERS+1][QuestionType];

int g_iChosenCategory[MAXPLAYERS+1] = {-1, ...};
int g_iChosenItem[MAXPLAYERS+1] = {-1, ...};
int g_iChosenMarketItem[MAXPLAYERS+1] = {-1, ...};
int g_iMarketItemCount[MAXPLAYERS+1] = {1, ...};
int g_iBoxOpeningAnimationState[MAXPLAYERS+1] = {BOX_OPENING_ANIM_COUNT, ...};
int g_iClientQuizAnswer[MAXPLAYERS+1] = {-1, ...};

// Macro funcs
#define LoopCategories(%1) for(int %1 = 0; %1 < MAX_CATEGORIES; %1++)

int g_iEquippedItem[MAXPLAYERS+1][MAX_CATEGORIES];

// HUD
int g_iHudEntity = -1;

Handle g_hForward_OnCreditsAdded, g_hForward_OnCreditsRemoved, g_hForward_OnCategoryFetched;

enum struct Category {
    int id;
    char name[MAX_NAME];
    char flags[MAX_FLAGS];
}

enum BoxType {
    BoxType_Common,
    BoxType_Rare,
    BoxType_Epic,
    BoxType_Legendary
}

enum struct Box {
    int entity_id;
    int owner;
    BoxType boxtype;
}


enum MoneyAction {
    MA_Add = 0,
    MA_Remove
}

enum struct Item {
    int itemid;
    int categoryid;
    int price;

    char name[MAX_NAME];
    char description[MAX_DESCRIPTION];
    char flags[MAX_FLAGS];
    char path[PLATFORM_MAX_PATH];
}

enum struct MarketItem {
    Item item;
    int count;

    char sSellerAuthId[128];
    char sBuyerAuthId[128];
}

enum struct Store {
    int credits;
    int userid;

    void add(int amt) {
        this.credits += amt;

        Call_StartForward(g_hForward_OnCreditsAdded);
        Call_PushCell(GetClientOfUserId(this.userid));
        Call_PushCell(amt);
        Call_Finish();
    }

    void remove(int amt) {
        this.credits -= amt;

        Call_StartForward(g_hForward_OnCreditsRemoved);
        Call_PushCell(GetClientOfUserId(this.userid));
        Call_PushCell(amt);
        Call_Finish();
    }
}
Store eStore[MAXPLAYERS+1];
Item g_ChosenItem[MAXPLAYERS+1];

char g_sBoxModels[1][] = {
	"models/klonken2020/misc/lootbox.mdl"
}

char g_sFileTypes[6][] = {
	".mdl",
	".vvd",
	".phy",
	".dx90.vtx",
	".vmt",
	".vtf"
};

char g_sBoxMaterials[1][] = {
	"materials/klonken2020/misc/lootbox.vmt"
}

char g_sBoxRarities[][] = {
    "Common",
    "Rare",
    "Epic",
    "Legendary"
}

int g_iCreditsPerType[BoxType] = {
    25,
    20,
    15,
    12
}

int g_iCreditIntervalPerType[BoxType][] = {
    {10, 50},
    {20, 70},
    {30, 80},
    {50, 100}
}

char g_sBoxRarityColors[][] = {
    "\x0A",
    "\x0B",
    "\x0E",
    "\x10"
}
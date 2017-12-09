#include <a_samp>
#include <YSI\y_ini>
#include <YSI\y_hooks>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <dini>

/*
1 = Mod
2 = Admin
3 = SuperAdmin
4 = HeadAdmin
5 = Owner
*/



#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_SUCCESS_1 3
#define DIALOG_SUCCESS_2 4
#define DIALOG_EDITID 5
#define DIALOG_EDIT 6
#define DIALOG_EDITPRICE 7
#define DIALOG_EDITINTERIOR 8
#define DIALOG_HCMDS 9


#define PATH "/Users/%s.ini"

#define ENEX_STREAMER_IDENTIFIER (100)

#define MAX_HOUSES 100



#define COL_WHITE "{FFFFFF}"
#define COL_GREEN "{00FF22}"
#define COL_LIGHTBLUE "{00CED1}"
#define COL_BLUE 0x0000FFAA
#define COL_YELLOW 0xFFFF00AA
#define COL_ORANGE 0xFFA500AA
#define COLOR_RED 0xFF0000AA
#define COLOR_BLUE 0x0000FFAA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_SYNTAX 0xFF6100AA
#define COL_RED "{F81414}"
#define COL_GREEN "{00FF22}"
#define COL_LIGHTBLUE "{00CED1}"
#define COLOR_ORANGE 0xFFA500AA

enum pInfo
{
	pPass,
	pMoney,
	pAdmin,
	pKills,
	pDeaths,
}
new PlayerInfo[MAX_PLAYERS][pInfo];

enum hInfo
{
	hPrice,
	hInterior,
	hOwned,
	hLocked,
	hPick,
	Text3D:hLabel,
	hOwner[MAX_PLAYER_NAME],
	Float:hX,
	Float:hY,
	Float:hZ,
	Float:hEnterX,
	Float:hEnterY,
	Float:hEnterZ,
}
new HouseInfo[MAX_HOUSES][hInfo];
new houseid;
new InHouse[MAX_PLAYERS][MAX_HOUSES];
new hid;


enum sData
{
	storeName[128],
	mapIcon,
	Float:entPos[4],
	Float:extPos[4],
	Float:robPos[3],
	interiorID,
	beingRobbed,
	recentlyRobbed,
	maxMoney,
	virtualID,
	entCP,
	extCP,
	robCP
}


new storeData[][sData]=
{
// 	 store Name					mapIcon 		{EntX, EntY,EntZ,EntAngle}							{ExtX, ExtY, ExtZ, ExtAngle} 						{RobX, RobY, RobZ{						//IntID 0 0 MaxMoney
	{"Well Stacked Pizza Co.",	29	,			{2104.7126, -1806.5319, 13.5547, 277.7998	},		{372.3442, 	-133.2576, 	1001.4922, 	179.2050	},	{374.1206, -119.2939, 	1001.4922	},	5,	0,	0,	35000},
	{"Burger Shot",				10	,			{810.9576,	-1616.1613,	13.5469, 262.7102	},		{363.1512,	-74.8533,	1001.5078,	317.3523	},	{376.1824,	-65.2047,	1001.5078	},	10,	0,	0,	35000},
	{"Burger Shot",				10	,			{1199.3285,	-918.6420,	43.1190, 187.8442	},		{363.1512,	-74.8533,	1001.5078,	317.3523	},  {376.1824,	-65.2047,	1001.5078	},	10,	0,	0,	35000},
	{"Cluckin' Bell",			14	,			{928.6047,	-1352.8942,	13.3438, 93.1771	},		{364.9270,	-11.5009,	1001.8516,	1.1029		},	{369.5536,	-6.5280,	1001.8589	},	9,	0,	0,	35000},
	{"Cluckin' Bell",			14	,			{2420.1423,	-1509.0582,	24.0000, 270.8312	},		{364.9270,	-11.5009,	1001.8516,	1.1029		},	{369.5536,	-6.5280,	1001.8589	},	9,	0,	0,	35000}

};

new DelayTick[MAX_PLAYERS];

main()
{
	print("\n----------------------------------");
	print(" Cops `n Robbers by Sorenkai");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	printf("--------------------------");
	printf("Robbery System Loading... ");
	new arr[3];
	arr[0] = ENEX_STREAMER_IDENTIFIER;
	for(new i=0; i!=sizeof(storeData); ++i)
	{
		storeData[i][entCP] = CreateDynamicCP(storeData[i][entPos][0], storeData[i][entPos][1], storeData[i][entPos][2]+0.5, 1, -1, -1, -1, 50);
		storeData[i][extCP] = CreateDynamicCP(storeData[i][extPos][0], storeData[i][extPos][1], storeData[i][extPos][2]+0.5, 1, i, storeData[i][interiorID], -1, 50);
		storeData[i][robCP] = CreateDynamicCP(storeData[i][robPos][0], storeData[i][robPos][1], storeData[i][robPos][2]+0.5, 3, i, storeData[i][interiorID], -1, 50);
		CreateDynamic3DTextLabel("[Entrance]", COLOR_YELLOW, storeData[i][entPos][0], storeData[i][entPos][1], storeData[i][entPos][2]+0.2, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 50);
		CreateDynamic3DTextLabel("[Exit]", COLOR_YELLOW, storeData[i][extPos][0], storeData[i][extPos][1], storeData[i][extPos][2] + 0.2, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 50);
		CreateDynamic3DTextLabel("[Rob]", COLOR_YELLOW, storeData[i][robPos][0], storeData[i][robPos][1], storeData[i][robPos][2]+0.2, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 50);
		CreateDynamicMapIcon(storeData[i][entPos][0], storeData[i][entPos][1], storeData[i][entPos][2], storeData[i][mapIcon], -1, .streamdistance = 200.0, .style = MAPICON_GLOBAL);
		storeData[i][virtualID] = i;
		arr[2] = i;

		Streamer_SetArrayData(STREAMER_TYPE_CP, storeData[i][entCP], E_STREAMER_EXTRA_ID, arr);
		Streamer_SetArrayData(STREAMER_TYPE_CP, storeData[i][extCP], E_STREAMER_EXTRA_ID, arr);
		Streamer_SetArrayData(STREAMER_TYPE_CP, storeData[i][robCP], E_STREAMER_EXTRA_ID, arr);
	}
	printf("Robbery System Loaded");
	printf("--------------------------");
	LoadHouses();
	SetGameModeText("CNR");
	DisableInteriorEnterExits();
	SetTimer("ServerRobbery", 1000, 1);
	AddStaticVehicleEx(470,1865.78295898,-2442.98876953,13.66469955,298.00000000,-1,-1,900); //Patriot
	AddStaticVehicleEx(470,1865.26049805,-2438.05322266,13.66469955,297.99865723,-1,-1,900); //Patriot
	AddStaticVehicleEx(470,1864.10070801,-2432.87500000,13.66469955,297.99865723,-1,-1,900); //Patriot
	AddStaticVehicle(425,315.7275,2051.5144,17.8182,176.6678,0,1); //
	AddStaticVehicle(425,304.6253,2056.8271,17.8100,180.2333,0,1); //
	AddStaticVehicle(425,296.5488,2059.0940,17.8253,188.7494,0,1);
	AddStaticVehicle(520,276.9792,2027.6726,17.6406,290.3594,0,1); //
	AddStaticVehicle(520,277.8985,1996.2645,17.6406,290.3594,0,1); //
	AddStaticVehicle(520,276.1920,1953.8641,17.6406,283.1623,0,1); //

	//LSPD Cars
	AddStaticVehicle(596,1538.6554,-1645.4680,5.6120,179.5933,0,1); // LSPD
	AddStaticVehicle(596,1530.4604,-1645.3107,5.6124,177.7601,0,1); // LSPD
	AddStaticVehicle(523,1546.4139,-1654.8896,5.4586,270.2880,0,0); // HPV
	AddStaticVehicle(596,1545.1909,-1680.1108,5.6098,268.8843,0,1); // LSPD
	AddStaticVehicle(596,1529.0856,-1683.8678,5.6119,90.2738,0,1); // LSPD
	AddStaticVehicle(411,1558.6659,-1710.4635,5.4839,180.4114,0,0); // undecover make black
	AddStaticVehicle(427,1587.5168,-1709.7181,6.0220,359.9041,0,1); // Enforcer
	AddStaticVehicle(490,1574.2781,-1709.8967,6.0200,0.7341,0,0); // FBI Rancher
	AddStaticVehicle(490,1578.5839,-1709.9985,6.0172,358.9602,0,0); // FBI Rancher
	AddStaticVehicle(596,1570.5350,-1710.4485,5.6105,179.5916,0,1); // LDPS
	AddStaticVehicle(596,1566.5233,-1710.3140,5.6121,179.4903,0,1); // LSPD
	AddStaticVehicle(596,1601.7191,-1704.3359,5.6108,268.6521,0,1); // LSPD
	AddStaticVehicle(402,1601.2964,-1692.0686,5.7223,90.0956,13,13); // Undercover FBI Car
	AddStaticVehicle(402,1601.1915,-1683.9227,5.7224,90.0514,22,22); // FBI Buffalo
	AddStaticVehicle(405,1600.9851,-1687.9960,5.7656,90.2003,24,1); // FBI Sentinel
	AddStaticVehicle(596,1544.2131,-1671.8967,5.6124,89.8306,0,1); // LSPD
	AddStaticVehicle(411,1544.4808,-1663.0748,5.4839,90.6810,6,6); // A-R Unit
	AddStaticVehicle(522,1543.5620,-1667.8304,5.4611,87.7870,3,8); // A-R Unit
	AddStaticVehicle(415,1544.1481,-1659.2570,5.6624,89.9421,25,1); // Cheetah
	AddStaticVehicle(497,1563.8291,-1647.2522,28.5786,87.9044,0,1); // LSPD Mav
	AddStaticVehicle(596,1535.8528,-1668.1055,13.1040,359.9227,0,1); // LSPD
	AddStaticVehicle(592,1442.0022,-2593.0347,14.7432,269.9402,1,1); // Andromada
	AddStaticVehicle(577,1442.0778,-2493.6089,13.4701,270.2746,8,16); // AT-400
	AddStaticVehicle(560,1362.9446,-1489.2616,13.2517,70.0243,9,39); // Street car
	AddStaticVehicle(400,441.1136,-1296.9650,15.2771,33.7294,123,1); //
	AddStaticVehicle(402,661.2392,-1263.4077,13.2974,180.4469,13,13); //
	AddStaticVehicle(404,727.5649,-1198.1158,18.9327,332.0143,119,50); //
	AddStaticVehicle(405,847.8672,-1153.2953,23.5313,270.5562,24,1); //
	AddStaticVehicle(410,592.4474,-1298.6516,14.3986,195.8924,9,1); //
	AddStaticVehicle(411,599.8068,-1296.5234,14.4330,198.7522,0,0); //
	AddStaticVehicle(412,295.3885,-1419.2489,13.7880,292.8682,10,8); //
	AddStaticVehicle(415,216.1153,-1431.7924,13.0211,134.5198,25,1); //
	AddStaticVehicle(419,198.1319,-1438.1703,12.8807,318.4540,47,76); //
	AddStaticVehicle(421,317.9250,-1809.6421,4.3541,180.2348,13,1); //
	AddStaticVehicle(422,337.3482,-1809.7214,4.4771,358.7836,97,25); //
	AddStaticVehicle(424,324.6066,-1788.1311,4.5653,0.6627,2,2); //
	AddStaticVehicle(411,393.5659,-1890.3940,1.1139,274.5846,85,85); //
	AddStaticVehicle(468,463.5244,-1823.6342,5.1035,268.1549,46,46); //
	AddStaticVehicle(474,495.4467,-1767.6510,5.3166,269.9758,81,1); //
	AddStaticVehicle(477,665.8559,-1886.1223,3.6893,266.2523,94,1); //
	AddStaticVehicle(481,682.4985,-1852.5225,5.4641,2.4120,3,3); //
	AddStaticVehicle(521,822.7520,-1699.5719,13.1165,359.5197,75,13); //
	AddStaticVehicle(526,686.4927,-1568.9868,14.0089,356.7253,9,39); //
	AddStaticVehicle(525,701.6587,-1571.7688,14.1193,180.8628,18,20); //
	AddStaticVehicle(446,719.8644,-1636.4723,-0.4465,357.0965,1,5); //
	AddStaticVehicle(448,783.1911,-1637.3964,12.9824,91.3249,3,6); //
	AddStaticVehicle(455,782.2476,-1605.8896,13.8189,358.5023,84,58); //
	AddStaticVehicle(457,838.4237,-1552.1782,13.0880,356.4117,2,1); //
	AddStaticVehicle(458,872.1634,-1505.1324,12.9550,89.3787,101,1); //
	AddStaticVehicle(461,815.1939,-1501.1245,12.6237,180.6368,37,1); //
	AddStaticVehicle(467,810.4442,-1448.8104,12.8154,87.3158,58,8); //
	AddStaticVehicle(560,869.7569,-1657.6364,13.2514,358.3217,17,1); //
	AddStaticVehicle(562,888.2688,-1669.5073,13.2046,179.9898,35,1); //
	AddStaticVehicle(565,874.4271,-1678.0381,13.1739,179.3548,42,42); //
	AddStaticVehicle(400,2247.7559,-1924.4431,13.6392,179.6043,123,1); //
	AddStaticVehicle(404,2283.6428,-1931.3055,12.7527,180.8797,119,50); //
	AddStaticVehicle(408,2311.1282,-1994.4446,14.1198,357.9063,26,26); //
	AddStaticVehicle(410,2495.6108,-1986.2244,13.0924,0.1197,9,1); //
	AddStaticVehicle(412,2452.2275,-2021.9824,13.3828,178.2901,10,8); //
	AddStaticVehicle(419,2395.0791,-2074.6975,13.3144,88.8546,47,76); //
	AddStaticVehicle(422,2444.3772,-2114.7273,13.5293,358.7563,97,25); //
	AddStaticVehicle(403,2488.6995,-2106.0339,14.1311,92.4613,30,1); //
	AddStaticVehicle(403,2489.3936,-2114.3250,14.1531,91.9732,28,1); //
	AddStaticVehicle(420,2504.0386,-1755.2026,13.1758,179.1026,6,1); //
	AddStaticVehicle(600,2494.6516,-1755.5043,13.1951,181.4729,32,8); //
	AddStaticVehicle(602,2498.2732,-1681.7469,13.1667,285.0013,69,1); //
	AddStaticVehicle(604,2508.1958,-1666.0525,13.1416,10.7108,68,76); //
	AddStaticVehicle(605,2484.1882,-1655.1521,13.1367,88.7774,32,8); //
	AddStaticVehicle(405,2278.9871,-1683.5277,14.0112,178.6860,24,1); //
	AddStaticVehicle(409,2063.2822,-1636.4720,13.3467,271.9295,1,1); //
	AddStaticVehicle(410,2051.8411,-1694.6627,13.2074,91.0224,36,1); //
	AddStaticVehicle(411,2122.1047,-1783.8508,12.9809,358.5475,0,0); //
	AddStaticVehicle(413,2100.7090,-1782.8505,13.4707,174.5412,105,1); //
	AddStaticVehicle(415,2062.4036,-1904.6412,13.3209,359.7023,40,1); //
	AddStaticVehicle(418,2062.2371,-1919.5068,13.6401,179.3507,108,108); //
	AddStaticVehicle(420,2339.9822,-2086.9375,13.3255,359.0136,6,1); //
	AddStaticVehicle(421,2086.5957,-2090.7112,13.4292,177.0427,25,1); //
	AddStaticVehicle(422,1773.1512,-2082.2983,13.5359,359.3152,111,31); //
	AddStaticVehicle(424,1745.4312,-2127.2371,13.3277,358.4977,2,2); //
	AddStaticVehicle(426,1699.6639,-2093.4856,13.2895,359.8446,42,42); //
	AddStaticVehicle(429,1762.8582,-2117.9116,13.1451,269.7401,13,13); //
	AddStaticVehicle(440,1261.2045,-1796.3574,13.5329,358.9323,32,32); //
	AddStaticVehicle(444,1277.7642,-1795.6394,13.7704,357.0524,32,42); //
	AddStaticVehicle(445,1135.2518,-1698.7494,13.6596,180.5404,35,35); //
	AddStaticVehicle(451,1066.1433,-1357.3958,13.0897,0.4214,125,125); //
	AddStaticVehicle(506,1219.2655,-1410.6830,12.9831,270.5204,6,6); //
	AddStaticVehicle(416,1181.3505,-1338.5973,13.8270,268.4014,1,3); // Ambulance
	AddStaticVehicle(420,1191.4980,-1325.6393,13.1773,179.8307,6,1); //
	AddStaticVehicle(420,1191.6094,-1346.1454,13.1793,179.2798,6,1); //
	AddStaticVehicle(428,1422.0940,-1344.5942,13.6948,1.6520,4,75); //
	AddStaticVehicle(439,1286.0500,-1137.3101,23.5523,90.4965,8,17); //
	AddStaticVehicle(444,1210.6799,-1100.1733,25.6637,183.2065,32,66); //

	//Airport (LS)
	AddStaticVehicleEx(519,1602.49316406,-2623.76196289,14.54694748,0.00000000,-1,-1,900); //Shamal
	AddStaticVehicleEx(519,1628.05786133,-2624.20629883,14.54694748,0.00000000,-1,-1,900); //Shamal
	AddStaticVehicleEx(519,1651.77563477,-2624.23461914,14.54694748,0.00000000,-1,-1,900); //Shamal
	AddStaticVehicleEx(519,1675.72583008,-2624.73730469,14.54694748,0.00000000,-1,-1,900); //Shamal
	AddStaticVehicleEx(519,1699.00317383,-2625.00097656,14.54694748,0.00000000,-1,-1,900); //Shamal
	AddStaticVehicleEx(593,1741.92358398,-2632.72705078,14.09705734,0.00000000,-1,-1,900); //Dodo
	AddStaticVehicleEx(593,1768.04223633,-2632.86157227,14.09705734,0.00000000,-1,-1,900); //Dodo
	AddStaticVehicleEx(513,1808.86926270,-2632.50317383,14.33163166,0.00000000,-1,-1,900); //Stunt
	AddStaticVehicleEx(513,1822.12475586,-2632.54833984,14.33163166,0.00000000,-1,-1,900); //Stunt
	AddStaticVehicleEx(513,1836.28283691,-2632.23925781,14.33163166,0.00000000,-1,-1,900); //Stunt
	AddStaticVehicleEx(417,1544.89050293,-2446.11743164,13.55468750,214.00000000,-1,-1,900); //Leviathan
	AddStaticVehicleEx(417,1564.89416504,-2443.75463867,13.55468750,214.00000000,-1,-1,900); //Leviathan
	AddStaticVehicleEx(487,1592.35961914,-2451.34326172,13.81968784,219.99993896,-1,-1,900); //Maverick
	AddStaticVehicleEx(487,1610.40087891,-2449.77563477,13.81968784,219.99572754,-1,-1,900); //Maverick


	AddStaticVehicle(560,1973.9471,-1728.3358,15.6740,268.8695,9,39); //
	AddStaticVehicle(562,1975.8925,-1692.5078,15.6274,89.3488,35,1); //
	AddStaticVehicle(565,2390.8472,-1493.9200,23.4575,90.1655,42,42); //
	AddStaticVehicle(566,2468.6011,-1545.9546,23.7828,91.7723,30,8); //
	AddStaticVehicle(571,2490.7092,-1558.2249,23.3647,274.2814,36,2); //
	AddStaticVehicle(573,2505.7622,-1535.7524,24.2679,177.8382,115,43); //
	AddStaticVehicle(600,2519.7258,-1537.2168,23.2535,356.8831,43,8); //
	AddStaticVehicle(602,2708.7246,-1189.6343,69.1237,268.4034,75,77); //
	AddStaticVehicle(603,2752.9653,-1110.0433,69.4163,0.2933,69,1); //
	AddStaticVehicle(604,2717.6113,-1315.8680,50.8129,179.5339,78,76); //
	AddStaticVehicle(605,2742.7874,-1460.3485,30.1806,358.7147,43,8); //
	AddStaticVehicle(400,2811.1116,-1432.4337,16.3437,3.4675,113,1); //
	AddStaticVehicle(521,2791.8081,-1429.3348,23.7543,87.3197,87,118); //
	AddStaticVehicle(411,2792.7446,-1449.6279,39.6498,90.4645,6,6); //
	AddStaticVehicle(411,2816.9929,-1446.2472,39.6563,269.7231,85,85); //
	AddStaticVehicle(451,2792.7192,-1432.4875,39.7681,87.0277,125,125); //
	AddStaticVehicle(522,2796.3882,-1549.6428,10.4898,90.1214,3,8); //
	AddStaticVehicle(526,2770.5667,-1605.5872,10.6885,90.7724,9,39); //
	AddStaticVehicle(527,2743.4241,-1614.7783,12.3851,357.6433,53,1); //
	AddStaticVehicle(529,2706.7659,-1842.8486,9.1274,338.6997,42,42); //
	AddStaticVehicle(533,2782.6765,-1875.7839,9.5195,178.4063,74,1); //
	AddStaticVehicle(534,2810.4614,-1837.1199,9.6499,267.8372,42,42); //
	AddStaticVehicle(568,2879.9138,-1859.3710,4.4213,325.5295,17,1); //
	AddStaticVehicle(424,2891.4314,-1909.1479,4.1350,181.9928,2,2); //
	AddStaticVehicle(468,2887.1760,-1994.7191,5.4558,178.6574,46,46); //
	AddStaticVehicle(493,2929.1023,-2057.4500,0.2582,87.0258,36,13); //
	AddStaticVehicle(452,2933.3682,-2045.4890,-0.5488,88.5820,1,5); //
	AddStaticVehicle(446,2920.5764,-2057.6011,0.0120,270.6396,1,5); //
	AddStaticVehicle(460,2952.2100,-2052.0940,2.1444,174.3388,1,9); //
	AddStaticVehicle(462,2740.0894,-1942.7235,13.1451,92.7067,13,13); //
	AddStaticVehicle(463,2749.6504,-2104.8103,11.5784,265.7299,84,84); //
	AddStaticVehicle(560,1928.6273,-2141.2437,13.2678,0.2657,21,1); //
	AddStaticVehicle(561,1946.8700,-2123.8020,13.3616,90.2954,8,17); //
	AddStaticVehicle(567,1798.6418,-2050.0444,13.4370,270.9849,88,64); //
	AddStaticVehicle(498,1751.4166,-2059.3850,13.7033,181.3239,13,120); //
	AddStaticVehicle(578,1773.9139,-2023.2332,14.6891,272.4109,1,1); //
	AddStaticVehicle(411,1479.6533,-1843.8639,13.1404,267.7712,56,56); //
	AddStaticVehicle(414,1476.0985,-1498.8483,13.6429,89.7816,28,1); //
	AddStaticVehicle(415,1479.3143,-1237.6947,13.8485,269.8049,20,1); //
	AddStaticVehicle(418,1330.8606,-1061.7308,28.6767,88.7811,119,119); //
	AddStaticVehicle(409,1276.3948,-1381.4437,13.0138,178.8206,1,1); //
	AddStaticVehicle(410,1282.5106,-1295.3256,13.0236,357.6100,36,1); //
	AddStaticVehicle(486,1242.0427,-1265.8451,13.6237,92.8921,1,1); //
	AddStaticVehicle(406,1268.8685,-1252.3369,15.1707,107.3903,1,1); //
	AddStaticVehicle(560,1059.4990,-1136.5386,23.4450,86.6929,56,29); //
	AddStaticVehicle(411,1056.4602,-1032.3748,31.6340,89.9467,1,1); //
	AddStaticVehicle(445,1028.3601,-1054.9408,31.5363,180.4680,37,37); //
	AddStaticVehicle(448,952.6252,-912.5894,45.3611,2.9908,3,6); //
	AddStaticVehicle(455,884.6342,-1137.4799,24.1322,90.4818,84,58); //
	AddStaticVehicle(456,851.4206,-1302.4886,13.7775,181.9248,91,63); //
	AddStaticVehicle(522,1050.4155,-1289.0911,13.0510,179.1246,39,106); //
	AddStaticVehicle(527,1014.6523,-1369.4447,12.8260,271.7850,75,1); //
	AddStaticVehicle(533,893.9490,-1360.1431,13.5758,269.0062,77,1); //
	AddStaticVehicle(535,738.0388,-1436.0945,13.3012,271.7214,28,1); //
	AddStaticVehicle(536,480.0226,-1516.8356,19.9839,184.6269,12,1); //
	AddStaticVehicle(540,544.4927,-1508.8596,14.2423,359.3493,42,42); //
	AddStaticVehicle(541,338.3979,-1607.2764,32.6801,0.8414,58,8); //
	AddStaticVehicle(543,784.3918,-820.5186,68.7186,194.3683,32,8); //
	AddStaticVehicle(545,812.9794,-768.5654,76.4932,104.2797,47,1); //
	AddStaticVehicle(546,1007.1812,-663.4985,120.8698,213.7551,78,38); //
	AddStaticVehicle(549,1361.4869,-620.4485,108.8300,104.8417,72,39); //
	AddStaticVehicle(572,1475.3203,-702.3226,92.4138,269.4503,116,1); //
	AddStaticVehicle(560,1530.3494,-812.9666,71.6773,270.7061,56,29); //
	AddStaticVehicle(561,1464.1514,-902.0443,54.6498,179.2653,54,38); //
	AddStaticVehicle(411,1172.2279,-881.3878,42.9081,97.9175,53,53); //
	AddStaticVehicle(600,1114.9319,-926.8351,42.8933,89.4798,32,8); //
	AddStaticVehicle(603,1095.8495,-869.3295,43.0182,89.3896,69,1); //
	AddStaticVehicle(400,980.6792,-904.2131,42.5927,183.5705,123,1); //
	AddStaticVehicle(404,834.5959,-925.2833,54.9829,60.9081,123,92); //
	AddStaticVehicle(405,833.2117,-860.1843,69.7675,19.6952,36,1); //
	AddStaticVehicle(410,796.7640,-843.6369,60.2915,11.2662,9,1); //
	AddStaticVehicleEx(405,2404.10546875,-1397.28955078,24.05439949,0.00000000,-1,-1,900); //Sentinel
	AddStaticVehicleEx(409,2357.95068359,-1363.88928223,23.94581604,0.00000000,-1,-1,900); //Stretch
	AddStaticVehicleEx(540,2386.35742188,-1351.78100586,24.45530510,0.00000000,-1,-1,900); //Vincent
	AddStaticVehicleEx(561,2376.14428711,-1320.61645508,23.92399979,0.00000000,-1,-1,900); //Stratum
	AddStaticVehicleEx(463,2348.61474609,-1263.26757812,22.12603378,272.00000000,-1,-1,900); //Freeway
	AddStaticVehicleEx(422,2347.32519531,-1252.51977539,22.57999992,270.00000000,-1,-1,900); //Bobcat
	AddStaticVehicleEx(554,2346.17163086,-1221.64086914,22.69499969,0.00000000,-1,-1,900); //Yosemite
	AddStaticVehicleEx(514,2411.67993164,-1228.56323242,24.99980736,0.00000000,-1,-1,900); //Tanker
	AddStaticVehicleEx(411,2428.06982422,-1227.90234375,24.91224670,0.00000000,-1,-1,900); //Infernus
	AddStaticVehicleEx(541,2471.79931641,-1251.54309082,26.46301270,89.99993896,-1,-1,900); //Bullet
	AddStaticVehicleEx(555,2506.51904297,-1277.77490234,34.63193512,179.99993896,-1,-1,900); //Windsor
	AddStaticVehicleEx(602,2516.76196289,-1297.55761719,34.75156403,0.00000000,-1,-1,900); //Alpha
	AddStaticVehicleEx(401,2506.51733398,-1366.55187988,28.39906502,177.99993896,-1,-1,900); //Bravura
	AddStaticVehicleEx(491,2517.00708008,-1393.34033203,28.43826675,0.00000000,-1,-1,900); //Virgo
	AddStaticVehicleEx(527,2683.12133789,-1429.45336914,30.29467773,0.00000000,-1,-1,900); //Cadrona
	AddStaticVehicleEx(533,2623.14672852,-1261.46813965,48.92050934,270.50000000,-1,-1,900); //Feltzer
	AddStaticVehicleEx(545,2137.59619141,-1283.52319336,24.75648880,0.00000000,-1,-1,900); //Hustler
	AddStaticVehicleEx(475,2196.45190430,-1286.17517090,24.09451103,0.00000000,-1,-1,900); //Sabre
	AddStaticVehicleEx(412,2256.12939453,-1287.19006348,24.53050232,0.00000000,-1,-1,900); //Voodoo
	AddStaticVehicleEx(518,2140.97241211,-1315.43017578,24.28842545,0.00000000,-1,-1,900); //Buccaneer
	AddStaticVehicleEx(536,2148.44506836,-1199.37609863,23.72622490,270.00000000,-1,-1,900); //Blade
	AddStaticVehicle(416,2037.1030,-1426.9613,17.0979,179.7931,1,3); // Ambulance
	AddStaticVehicle(416,2026.4424,-1409.2092,17.0986,90.3309,1,3); // Ambulance
	AddStaticVehicle(481,1944.9799,-1423.3868,9.8702,99.7650,3,3); // bmx
	AddStaticVehicle(522,1889.6011,-1433.0640,9.9852,208.0781,36,105); // NRG
	AddStaticVehicle(471,1908.2617,-1388.4788,9.8670,60.9329,103,111); // Quatd
	AddStaticVehicle(560,1842.8820,-1309.2706,13.0958,179.4665,37,0); // Sultan
	AddStaticVehicle(481,1907.0743,-1220.4691,17.3505,326.9318,6,6); // BMX
	AddStaticVehicle(411,1910.5283,-1123.9529,24.9005,1.0823,1,1); // Infernus
	AddStaticVehicle(506,1989.7363,-1119.2100,26.5294,88.4550,7,7); // Super GT
	AddStaticVehicle(491,2086.0562,-1140.2959,24.7930,268.7915,64,72); // Virgo
	AddStaticVehicle(492,2161.5000,-1177.9441,23.6004,270.3815,77,26); // Greenwood
	AddStaticVehicle(496,2148.7170,-1148.0298,24.1607,88.0711,66,72); //
	AddStaticVehicle(471,2309.2771,-1052.1664,49.9301,342.6730,74,91); //
	AddStaticVehicle(600,2344.2231,-1059.2657,52.8345,289.9105,83,13); //
	AddStaticVehicle(478,2385.0522,-1029.8955,53.6107,316.6493,66,1); //
	AddStaticVehicle(479,2429.7053,-1019.3953,53.9940,193.6098,59,36); //
	AddStaticVehicle(482,2452.3965,-1050.4058,59.7480,356.6701,48,48); //
	AddStaticVehicle(483,2570.6553,-1030.9257,69.5739,357.5074,1,31); //
	AddStaticVehicle(489,2597.9280,-1062.3071,69.7218,1.1586,14,123); //
	AddStaticVehicle(491,1622.1725,-1094.0273,23.6663,90.7516,52,66); //
	AddStaticVehicle(561,1632.4114,-1013.2068,23.7127,341.4184,65,79); //
	AddStaticVehicle(562,1685.1648,-1035.7760,23.5654,179.1545,113,1); //
	AddStaticVehicle(566,1692.5903,-1084.7720,23.6853,180.2076,83,1); //
	AddStaticVehicle(515,1651.2184,-1886.2770,14.5733,268.2462,24,77); //
	AddStaticVehicle(518,1838.0511,-1871.3605,13.0550,179.1560,9,39); //
	AddStaticVehicle(521,1804.8612,-1930.3901,12.9552,178.1389,87,118); //
	AddStaticVehicle(492,1780.0067,-1932.6024,13.1682,181.3466,28,56); //
	AddStaticVehicle(496,1804.9237,-1694.1798,13.2584,5.0938,37,19); //
	AddStaticVehicle(494,1782.0830,-1702.2521,13.4023,1.4439,42,33); //
	AddStaticVehicle(499,1609.2104,-1669.8256,13.5386,0.9787,109,32); //
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(fexist(UserPath(playerid))){
		INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Login",""COL_WHITE"Enter your password below to log in.", "Login", "Quit");
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Register",""COL_WHITE"Enter your desired password below to register a new account.","Register" , "Quit");
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new INI:File = INI_Open(UserPath(playerid));
	INI_SetTag(File, "data");
	INI_WriteInt(File, "Money", GetPlayerMoney(playerid));
	INI_WriteInt(File, "Admin", PlayerInfo[playerid][pAdmin]);
	INI_WriteInt(File, "Kills", PlayerInfo[playerid][pKills]);
	INI_WriteInt(File, "Deaths", PlayerInfo[playerid][pDeaths]);
	INI_Close(File);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	PlayerInfo[killerid][pKills]++;
	PlayerInfo[playerid][pDeaths]++;
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{

	new arr[2];
	Streamer_GetArrayData(STREAMER_TYPE_CP, checkpointid, E_STREAMER_EXTRA_ID, arr);

	if(arr[0] == ENEX_STREAMER_IDENTIFIER)
	{
		if((gettime() - DelayTick[playerid]) < 3)
		{
			return 1;
		}
		if(checkpointid == storeData[arr[1]][entCP])
		{
			DelayTick[playerid] = gettime();
			SetPlayerVirtualWorld(playerid, storeData[arr[1]][virtualID]);
			SetPlayerInterior(playerid, storeData[arr[1]][interiorID]);

			SetPlayerPos(playerid, storeData[arr[1]][extPos][0], storeData[arr[1]][extPos][1], storeData[arr[1]][extPos][2]);
			SetPlayerFacingAngle(playerid, storeData[arr[1]][extPos][3]);
			SetCameraBehindPlayer(playerid);
		}	
		if(checkpointid == storeData[arr[1]][extCP])
		{
			DelayTick[playerid] = gettime();
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerPos(playerid, storeData[arr[1]][entPos][0], storeData[arr[1]][entPos][1], storeData[arr[1]][entPos][2]);
			SetPlayerFacingAngle(playerid, storeData[arr[1]][entPos][3]);
			SetCameraBehindPlayer(playerid);

		}
		if(checkpointid == storeData[arr[1]][robCP])
		{
			SendClientMessage(playerid, COLOR_RED, "[ROBBERY] Start a robbery by typing /rob");

		}
	}
	#if defined hk_OnPlayerEnterDynamicCP
		return hk_OnPlayerEnterDynamicCP(playerid, checkpointid)
	#else
		return 1;
	#endif
}

#if defined _ALS_OPPDP
	#undef OnPlayerEnterDynamicCP
#else
	#define _ALS_OPPDP
#endif

public OnPlayerLeaveDynamicCP(playerid, checkpointid)
{
	new arr[2];
	Streamer_GetArrayData(STREAMER_TYPE_CP, checkpointid, E_STREAMER_EXTRA_ID, arr);
	if(storeData[arr[1]][beingRobbed] >= 1)
	{
		SendClientMessage(playerid, COLOR_RED, "[ROBBERY] Robbery Failed");
		storeData[arr[1]][beingRobbed] = 0;
		return 1;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(!response) return Kick(playerid);
			if(response)
			{
				if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Register", ""COL_RED"You have entered an invalid password.\n"COL_WHITE"Enter your desired password below to register a new account.", "Register" ,"Quit");
				new INI:File = INI_Open(UserPath(playerid));
				INI_SetTag(File, "data");
				INI_WriteInt(File, "Password", udb_hash(inputtext));
				INI_WriteInt(File, "Cash", 0);
				INI_WriteInt(File,"Admin",0);
				INI_WriteInt(File, "Kills", 0);
				INI_WriteInt(File, "Deaths", 0);
				INI_Close(File);

				SetSpawnInfo(playerid, 0, 0, 1958.33, 1343.12, 15.36, 269.15, 0, 0, 0, 0, 0, 0);
				SpawnPlayer(playerid);
				ShowPlayerDialog(playerid, DIALOG_SUCCESS_1, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Success!", ""COL_GREEN"You have successfully registered!", "Continue","");

			}
		}
		case DIALOG_LOGIN:
		{
			if(!response) return Kick(playerid);
			if(response)
			{
				if(udb_hash(inputtext) == PlayerInfo[playerid][pPass])
				{
					INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
					GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
					ShowPlayerDialog(playerid, DIALOG_SUCCESS_2, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Success!", ""COL_GREEN"You have successfully logged in!", "Continue", "");				
				}
				else
				{
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Login", ""COL_WHITE"Enter your password below to log in.", "Login.", "Quit.");
				}
			}

		}
		case DIALOG_EDITID:
		{
			if(response)
                {
                        new string[144], file[50];
                        hid = strval(inputtext);
                        format(file, sizeof(file), "Houses/%d.ini", hid);
                        if(!fexist(file)) return SendClientMessage(playerid, -1, "{FF0000}ERROR: {FFFFFF}This house doesn't exist in data-base.");
                        format(string, sizeof(string), "{FF0000}[EDIT-MODE]: {FFFFFF}Currently editing house: {FF0000}%d.", strval(inputtext));
                        SendClientMessage(playerid, -1, string);
                        ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                else
                {
                        SendClientMessage(playerid, -1, "{FF0000}[HOUSE]: {FFFFFF}You can't edit this house now.");
                }
		}
		case DIALOG_EDIT:
		{
			if(response)
            {
                if(listitem == 0)
                {
                    ShowPlayerDialog(playerid, DIALOG_EDITPRICE, DIALOG_STYLE_INPUT, "Edit Price", "{FFFFFF}Please, input below new house's price:", "Continue", "Back");
                }
                if(listitem == 1)
                {
                    ShowPlayerDialog(playerid, DIALOG_EDITINTERIOR, DIALOG_STYLE_INPUT, "Edit Interior", "{FFFFFF}Please, input below house's interior:", "Continue", "Back");
                }
                if(listitem == 2)
                {
                	new file[50], string[144];
                	HouseInfo[hid][hOwned] = 0;
                	format(file, sizeof(file), "Houses/%d.ini", hid);
                	if(fexist(file))
                	{
                	    dini_IntSet(file, "Owned", 0);
                	}
                	format(string, sizeof(string), "{FF0000}[EDIT-MODE]: {FFFFFF}House setted ownable.");
                	SendClientMessage(playerid, -1, string);
                	ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                if(listitem == 3)
                {
                    HouseInfo[hid][hLocked] = 1;
                    SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}House locked.");
                    ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                if(listitem == 4)
                {
                    HouseInfo[hid][hLocked] = 0;
                    SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}House unlocked.");
                    ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                if(listitem == 5)
                {
                    SetPlayerPos(playerid, HouseInfo[hid][hX], HouseInfo[hid][hY], HouseInfo[hid][hZ]);
        			SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}Teleported to house.");
                    ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                if(listitem == 6)
                {
        			SetPlayerPos(playerid, HouseInfo[hid][hX], HouseInfo[hid][hY], HouseInfo[hid][hZ]);
        			SetPlayerInterior(playerid, HouseInfo[hid][hInterior]);
        			SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}Entered in house.");
                }
                if(listitem == 7)
                {
            		SetPlayerPos(playerid, HouseInfo[hid][hX], HouseInfo[hid][hY], HouseInfo[hid][hZ]);
                    SetPlayerInterior(playerid, 0);
            		SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}House exited to pick-up position.");
                    ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_EDITID, DIALOG_STYLE_INPUT, "House ID", "{FFFFFF}Please, input below house ID wich you want to edit:", "Continue", "Exit");
            }
		}
		case DIALOG_EDITPRICE:
		{
			if(response)
            {
                new file[50], string[144];
                HouseInfo[hid][hPrice] = strval(inputtext);
                format(file, sizeof(file), "Houses/%d.ini", hid);
                if(fexist(file))
                {
                    dini_IntSet(file, "Price", HouseInfo[hid][hPrice]);
                }
                format(string, sizeof(string), "{FF0000}[EDIT-MODE]: {FFFFFF}New price of house: {FF0000}%d {FFFFFF}it's {FF0000}%d.", hid, HouseInfo[hid][hPrice]);
                SendClientMessage(playerid, -1, string);
                ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
            }
            else
            {
            	ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
            }

		}
		case DIALOG_EDITINTERIOR:
		{
			if(response)
            {
            	new file[50], string[144];
                HouseInfo[hid][hInterior] = strval(inputtext);
                format(file, sizeof(file), "Houses/%d.ini", hid);
                if(fexist(file))
                {
                        dini_IntSet(file, "Interior", HouseInfo[hid][hInterior]);
                }
                format(string, sizeof(string), "{FF0000}[EDIT-MODE]: {FFFFFF}New interior of house: {FF0000}%d {FFFFFF}it's {FF0000}%d.", hid, HouseInfo[hid][hInterior]);
                SendClientMessage(playerid, -1, string);
                ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
            }
            else
            {
        		ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
            }
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}


stock UserPath(playerid)
{
	new string[128],pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid,pName,sizeof(pName));
	format(string, sizeof(string),PATH,pName);
	return string;

}

stock LoadHouses()
{
    new file[50], labelstring[144], stringlabel[144];
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        format(file, sizeof(file), "Houses/%d.ini", i);
        if(fexist(file))
        {
            HouseInfo[i][hOwned] = dini_Int(file, "Owned");
            HouseInfo[i][hPrice] = dini_Int(file, "Price");
            HouseInfo[i][hInterior] = dini_Int(file, "Interior");
            HouseInfo[i][hX] = dini_Float(file, "Position X");
            HouseInfo[i][hY] = dini_Float(file, "Position Y");
            HouseInfo[i][hZ] = dini_Float(file, "Position Z");
            HouseInfo[i][hEnterX] = dini_Float(file, "Enter X");
            HouseInfo[i][hEnterY] = dini_Float(file, "Enter Y");
            HouseInfo[i][hEnterZ] = dini_Float(file, "Enter Z");
            strmid(HouseInfo[i][hOwner], dini_Get(file, "Owner"), false, strlen(dini_Get(file, "Owner")), MAX_PLAYER_NAME);
			format(labelstring, sizeof(labelstring), "{15FF00}House ID: {FFFFFF}%d\n{15FF00}Status: {FFFFFF}For Sale\n{15FF00}Price: {FFFFFF}%d", i, HouseInfo[i][hPrice]);
			format(stringlabel, sizeof(stringlabel), "{15FF00}House ID: {FFFFFF}%d\n{15FF00}Owner: {FFFFFF}%s\n{15FF00}Price: {FFFFFF}%d", i, HouseInfo[i][hOwner], HouseInfo[i][hPrice]);
            if(HouseInfo[i][hOwned] == 0)
            {
                HouseInfo[i][hPick] = CreatePickup(1273, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
                HouseInfo[i][hLabel] = Create3DTextLabel(labelstring, 0xFFFFFFFF, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 30.0, 0, 0);
            }
            else if(HouseInfo[i][hOwned] == 1)
            {
                HouseInfo[i][hPick] = CreatePickup(1272, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
                HouseInfo[i][hLabel] = Create3DTextLabel(stringlabel, 0xFFFFFFFF, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 30.0, 0, 0);
            }
            houseid++;
        }
    }
    print(" ");
    print(" ");
    printf("  LOADED HOUSE: %d/%d", houseid, MAX_HOUSES);
    print(" ");
    print(" ");
    return 1;
}

/*Credits to Dracoblue*/
stock udb_hash(buf[]) {
	new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}

forward ServerRobbery();
public ServerRobbery()
{
	for(new i; i<MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(storeData[i][beingRobbed] > 1)
			{
				storeData[i][beingRobbed] --;
				new time[20];
				format(time, sizeof(time), "~r~Robbery Time:~y~ %d",storeData[i][beingRobbed]);
				GameTextForPlayer(i, time, 500, 3);

			}
			if(storeData[i][beingRobbed] == 1)
			{
				new string[256], pName[MAX_PLAYER_NAME];
				GetPlayerName(i, pName, MAX_PLAYER_NAME);
				SendClientMessage(i, COLOR_GREEN, "[ROBBERY] Robbery Complete!");
				SetPlayerWantedLevel(i, GetPlayerWantedLevel(i)+1);
				storeData[i][beingRobbed] = 0;
				new mrand = random(storeData[i][maxMoney]);
				GivePlayerMoney(i, mrand);
				format(string, sizeof(string), "[ROBBERY] %s(%d) has robbed a total of $%d from %s ", pName,i,mrand,storeData[i][storeName]);
				SendClientMessageToAll(COLOR_GREEN, string);
				GivePlayerMoney(i, mrand);
			}
		}
	}
	return 1;
}

forward LoadUser_data(playerid, name[],value[]);
public LoadUser_data(playerid, name[],value[])
{
	INI_Int("Password", PlayerInfo[playerid][pPass]);
	INI_Int("Money", PlayerInfo[playerid][pMoney]);
	INI_Int("Admin", PlayerInfo[playerid][pAdmin]);
	INI_Int("Kills", PlayerInfo[playerid][pKills]);
	INI_Int("Deaths", PlayerInfo[playerid][pDeaths]);
	return 1;
}

CMD:rob(playerid, params[])
{
	#pragma unused params
	new args[2], string[256], pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	if(IsPlayerInDynamicCP(playerid, storeData[args[1]][robCP]))
	{
		if(storeData[args[1]][recentlyRobbed] >= 1)
		{
			format(string, sizeof(string),"[ROBBERY] This %s has been robbed recently.",storeData[args[1]][storeName]);
			SendClientMessage(playerid, COLOR_RED, string);
			return 1;
		}
		storeData[args[1]][beingRobbed] = 60;
		storeData[args[1]][recentlyRobbed] = 180;
		format(string, sizeof(string), "[ROBBERY] %s(%d) has started a robbery at a %s", pName,playerid, storeData[args[1]][storeName]);
		SendClientMessageToAll(COLOR_BLUE, string);
	}
	return 1;
}

CMD:createhouse(playerid,params[])
{
	new Price, Level, string[144], Float:X, Float:Y, Float:Z, labelstring[144], file[50];
	GetPlayerPos(playerid, X, Y, Z);
	if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] Your admin level is not high enough!");
	if(sscanf(params, "ii", Price,Level)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /createhouse <price> <level>");
	if(Level > 5 || Level < 1) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] Invalid Level [1-5]");
	if(Level == 1)
	{
		HouseInfo[houseid][hEnterX] = 2216.540087;
		HouseInfo[houseid][hEnterY] = -1078.869995;
		HouseInfo[houseid][hEnterZ] = 1049.023437;
		HouseInfo[houseid][hInterior] = 2;
		SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] Interior Set #1");
	}
	else if(Level == 2)
	{
		HouseInfo[houseid][hEnterX] = 2216.540039;
		HouseInfo[houseid][hEnterY] = -1076.290039;
		HouseInfo[houseid][hEnterZ] = 1050.484375;
		HouseInfo[houseid][hInterior] = 1;
		SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] Interior Set #2");
	}
	else if(Level == 3)
	{
		HouseInfo[houseid][hEnterX] = 2282.909912;
		HouseInfo[houseid][hEnterY] = -1137.971191;
		HouseInfo[houseid][hEnterZ] = 1050.898437;
		HouseInfo[houseid][hInterior] = 11;
		SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] Interior Set #3");
	}
	else if(Level == 4)
	{
		HouseInfo[houseid][hEnterX] = 2365.300048;
		HouseInfo[houseid][hEnterY] = -1132.920043;
		HouseInfo[houseid][hEnterZ] = 1050.875000;
		HouseInfo[houseid][hInterior] = 8;
		SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] Interior Set #4");		
	}
	else if(Level == 5)
	{
        HouseInfo[houseid][hEnterX] = 1299.079956;
        HouseInfo[houseid][hEnterY] = -795.226989;
        HouseInfo[houseid][hEnterZ] = 1084.007812;
        HouseInfo[houseid][hInterior] = 5;
        SendClientMessage(playerid, -1, "{FF0000}[HOUSE]: {FFFFFF}House Interior setted. {FF0000}#5.");
	}

	format(string, sizeof(string), "[HOUSE] House ID: %d created", houseid);
	SendClientMessage(playerid, COLOR_GREEN, string);
	format(labelstring, sizeof(labelstring), "{15FF00}House ID: {FF0000}%d\n{15FF00}Status: {FFFFFF} For Sale\n{15FF00}Price: {FFFFFF}$%d", houseid,Price);
	HouseInfo[houseid][hOwned] = 0;
	HouseInfo[houseid][hX] = X;
	HouseInfo[houseid][hY] = Y;
	HouseInfo[houseid][hZ] = Z;
	HouseInfo[houseid][hPick] = CreatePickup(1273, 1, X, Y, Z, 0);
	HouseInfo[houseid][hLabel] = Create3DTextLabel(labelstring, 0xFFFFFFFF, X, Y, Z, 30, 0, 0);
	format(file, sizeof(file),"Houses/%d.ini",houseid);
	if(!fexist(file))
	{
		dini_Create(file);
		dini_IntSet(file,"Price",Price);
		dini_IntSet(file,"Interior",HouseInfo[houseid][hInterior]);
		dini_IntSet(file,"Level",Level);
		dini_FloatSet(file,"Position X",X);
		dini_FloatSet(file,"Position Y",Y);
		dini_FloatSet(file,"Position Z",Z);
		dini_FloatSet(file,"Enter X",HouseInfo[houseid][hEnterX]);
		dini_FloatSet(file,"Enter Y",HouseInfo[houseid][hEnterY]);
		dini_FloatSet(file,"Enter Z",HouseInfo[houseid][hEnterZ]);
	}
	houseid++;
	return 1;
}

CMD:buyhouse(playerid, params[])
{
    new name[MAX_PLAYER_NAME], labelstring[144], string[144], file[50];
    GetPlayerName(playerid, name, sizeof(name));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
        {
            if(HouseInfo[i][hOwned] == 1) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] This house has already been bought");
            if(GetPlayerMoney(playerid) < HouseInfo[i][hPrice]) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You don't have enough money to buy this house");
            DestroyPickup(HouseInfo[i][hPick]);
            format(labelstring, sizeof(labelstring), "{15FF00}House ID: {FFFFFF}%d\n{15FF00}Owner: {FFFFFF}%s\n{15FF00}Price: {FFFFFF}%d", i, name, HouseInfo[i][hPrice]);
            HouseInfo[i][hPick] = CreatePickup(1272, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
            Update3DTextLabelText(HouseInfo[i][hLabel], 0xFFFFFFFF, labelstring);
            format(labelstring, sizeof(labelstring), "{FF0000}[HOUSE]: {FFFFFF}You bought house ID: {FF0000}%d {FFFFFF}for {FF0000}$ %d.", i, HouseInfo[i][hPrice]);
            SendClientMessage(playerid, -1, string);
            HouseInfo[i][hOwned] = 1;
            HouseInfo[i][hOwner] = name;
            format(file, sizeof(file), "Houses/%d.ini", i);
            if(fexist(file))
            {
                dini_IntSet(file, "Owned", 1);
                dini_Set(file, "Owner", name);
            }
            GivePlayerMoney(playerid, -HouseInfo[i][hPrice]);
        }
    }
    return 1;
}

CMD:sellhouse(playerid, params[])
{
    new pname[MAX_PLAYER_NAME], labelstring[144], string[144], file[50];
    GetPlayerName(playerid, pname, sizeof(pname));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
        {
            if(HouseInfo[i][hOwned] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You cannot sell this house");
            if(strcmp(pname, HouseInfo[i][hOwner], true)) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You aren't Owner of this house");
            format(labelstring, sizeof(labelstring), "{15FF00}House ID: {FFFFFF}%d\n{15FF00}Status: {FFFFFF}For Sale\n{15FF00}Price: {FFFFFF}%d", i, HouseInfo[i][hPrice]);
            DestroyPickup(HouseInfo[i][hPick]);
            HouseInfo[i][hPick] = CreatePickup(1273, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 0);
            Update3DTextLabelText(HouseInfo[i][hLabel], 0xFFFFFFFF, labelstring);
            format(string, sizeof(string), "{FF0000}[HOUSE]: {FFFFFF}You've sold your house: {FF0000}%d.", i);
            SendClientMessage(playerid, -1, string);
            HouseInfo[i][hOwned] = 0;
            HouseInfo[i][hOwner] = 0;
            format(file, sizeof(file), "Houses/%d.ini", i);
            if(fexist(file))
            {
                dini_IntSet(file, "Owned", 0);
                dini_Set(file, "Owner", " ");
            }
            GivePlayerMoney(playerid, HouseInfo[i][hPrice]);
        }
    }
    return 1;
}

CMD:enterhouse(playerid, params[])
{
        for(new i = 0; i < MAX_HOUSES; i++)
        {
                if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
                {
                        if(HouseInfo[i][hLocked] == 1) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] This house is locked");
                        if(HouseInfo[i][hOwned] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You cannot enter this house");
                        SetPlayerPos(playerid, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ]);
                        SetPlayerInterior(playerid, HouseInfo[i][hInterior]);
                        SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] You've entered a house.");
                        InHouse[playerid][i] = 1;
                }
        }
        return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:exithouse(playerid, params[])
{
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(InHouse[playerid][i] == 1)
        {
            SetPlayerPos(playerid, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
            SetPlayerInterior(playerid, 0);
            SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] You've exited a house.");
            InHouse[playerid][i] = 0;
        }
    }
    return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:lockhouse(playerid, params[])
{
    new pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
        {
            if(HouseInfo[i][hOwned] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You can't lock this house");
            if(HouseInfo[i][hLocked] == 1) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] This house is already locked");
            if(strcmp(pname, HouseInfo[i][hOwner], true)) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You aren't owner of this house");
            SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] You've locked your house.");
            GameTextForPlayer(playerid, "House ~r~Locked", 5000, 3);
            HouseInfo[i][hLocked] = 1;
        }
    }
    return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:unlockhouse(playerid, params[])
{
    new pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
        {
            if(HouseInfo[i][hOwned] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You can't enter this house");
            if(HouseInfo[i][hLocked] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] This house is already unlocked");
            if(strcmp(pname, HouseInfo[i][hOwner], true)) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You aren't owner of this house");
            SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] You've unlocked your house");
            GameTextForPlayer(playerid, "House ~g~UnLocked", 5000, 3);
            HouseInfo[i][hLocked] = 0;
        }
    }
    return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:edithouse(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] Your admin level is not high enough");
    ShowPlayerDialog(playerid, DIALOG_EDITID, DIALOG_STYLE_INPUT, "House ID", "{FFFFFF}Please, input below house ID wich you want to edit:", "Continue", "Exit");
    return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:housecmds(playerid, params[])
{
        new Dialog[512];
        strcat(Dialog, "{FF0000}h-House Commands.\n\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/HouseCMDS {FFFFFF}- See this list with all commands.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/BuyHouse {FFFFFF}- Buy a house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/SellHouse {FFFFFF}- Sell your house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/EnterHouse {FFFFFF}- Enter in a house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/ExitHouse {FFFFFF}- Exit from a house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/LockHouse {FFFFFF}- Locks your house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/UnlockHouse {FFFFFF}- Unlocks your house.\n\n", sizeof(Dialog));
        strcat(Dialog, "{FF0000}/CreateHouse {15FF00}- Creates a house [LOGGED AS RCON].", sizeof(Dialog));
    	ShowPlayerDialog(playerid, DIALOG_HCMDS, DIALOG_STYLE_MSGBOX, "House Commands", Dialog, "Exit", "");
        return 1;
}

#include "cmds/admincmds.pwn"
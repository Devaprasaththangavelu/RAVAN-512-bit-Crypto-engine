module keyslicer_v1 (
    input  wire [511:0] key,
    output wire [63:0] sliced_key1, sliced_key2, sliced_key3, sliced_key4,
    output wire [63:0] sliced_key5, sliced_key6, sliced_key7, sliced_key8
);

    wire [63:0] sliced_key [0:7];

    
    
    assign sliced_key[0] = {
        key[493], key[343],  key[301], key[364],  key[109], key[411], key[2],   key[89],
        key[330], key[447],  key[429], key[120], key[481], key[511], key[33],  key[15],
        key[200], key[386],  key[312], key[44],  key[77],  key[150], key[401], key[22],
        key[199], key[350],  key[6],   key[377],  key[410], key[315], key[121], key[500],
        key[42],  key[18],   key[240], key[134], key[390], key[256], key[10],  key[176],
        key[95],  key[311],  key[144], key[260], key[275], key[80],  key[400], key[305],
        key[198], key[450],  key[505], key[1],   key[333], key[111], key[60],  key[280],
        key[222], key[167],  key[48],  key[340], key[99],  key[123], key[9],   key[430]
    };

    assign sliced_key[1] = {
        key[23],  key[491], key[175], key[209], key[321], key[46],  key[288], key[105],
        key[45],  key[382], key[24],  key[163], key[509], key[215], key[388], key[64],
        key[132], key[308], key[271], key[155], key[244], key[441], key[31],  key[190],
        key[265], key[110], key[281], key[422], key[56],  key[187], key[399], key[52],
        key[13],  key[250], key[145], key[261], key[371], key[34],  key[205], key[460],
        key[178], key[228], key[508], key[29],  key[70],  key[360], key[415], key[90],
        key[8],   key[235], key[112], key[298], key[335], key[185], key[490], key[30],
        key[444], key[59],  key[125], key[368], key[251], key[349], key[158], key[212]
    };

    assign sliced_key[2] = {
        key[416], key[78],  key[302], key[437], key[472], key[225], key[4],   key[116],
        key[355], key[91],  key[136], key[278], key[448], key[39],  key[290], key[488],
        key[169], key[504], key[211], key[83],  key[341], key[26],  key[402], key[318],
        key[146], key[258], key[74],  key[431], key[180], key[462], key[231], key[358],
        key[51],  key[195], key[379], key[268], key[102], key[425], key[14],  key[320],
        key[94],  key[241], key[361], key[501], key[128], key[476], key[218], key[338],
        key[66],  key[309], key[152], key[438], key[285], key[19],  key[404], key[373],
        key[252], key[170], key[485], key[35],  key[496], key[202], key[118], key[325]
    };

    assign sliced_key[3] = {
        key[374], key[137], key[27],  key[299], key[455], key[161], key[385], key[245],
        key[53],  key[181], key[328], key[405], key[68],  key[494], key[106], key[232],
        key[352], key[20],  key[273], key[435], key[141], key[300], key[85],  key[473],
        key[219], key[114], key[365], key[253], key[468], key[73],  key[193], key[412],
        key[36],  key[153], key[282], key[392], key[58],  key[316], key[224], key[104],
        key[484], key[5],   key[266], key[174], key[344], key[92],  key[440], key[126],
        key[207], key[331], key[499], key[63],  key[291], key[160], key[420], key[238],
        key[47],  key[380], key[506], key[248], key[304], key[451], key[11],  key[135]
    };

    assign sliced_key[4] = {
        key[179], key[395], key[262], key[142], key[479], key[61],  key[322], key[216],
        key[366], key[82],  key[503], key[286], key[428], key[25],  key[204], key[456],
        key[117], key[239], key[72],  key[346], key[156], key[492], key[295], key[108],
        key[41],  key[188], key[313], key[445], key[131], key[270], key[375], key[249],
        key[469], key[93],  key[213], key[334], key[406], key[164], key[432], key[57],
        key[197], key[359], key[229], key[79],  key[418], key[495], key[306], key[122],
        key[510], key[255], key[38],  key[151], key[389], key[289], key[87],  key[464],
        key[226], key[354], key[16],  key[408], key[486], key[184], key[326], key[7]
    };

    assign sliced_key[5] = {
        key[434], key[247], key[101], key[336], key[459], key[177], key[283], key[65],
        key[363], key[206], key[498], key[143], key[263], key[398], key[49],  key[303],
        key[220], key[129], key[478], key[96],  key[319], key[165], key[414], key[37],
        key[194], key[348], key[507], key[75],  key[276], key[442], key[115], key[242],
        key[383], key[234], key[133], key[426], key[54],  key[292], key[154], key[466],
        key[370], key[17],  key[403], key[210], key[324], key[84],  key[182], key[351],
        key[480], key[69],  key[259], key[147], key[394], key[201], key[452], key[103],
        key[272], key[3],   key[487], key[332], key[417], key[127], key[227], key[307]
    };

    assign sliced_key[6] = {
        key[264], key[387], key[139], key[427], key[62],  key[186], key[353], key[470],
        key[217], key[97],  key[296], key[159], key[409], key[40],  key[453], key[317],
        key[50],  key[362], key[446], key[119], key[236], key[497], key[279], key[81],
        key[196], key[376], key[166], key[461], key[339], key[107], key[257], key[436],
        key[28],  key[396], key[208], key[483], key[148], key[293], key[329], key[76],
        key[458], key[233], key[130], key[369], key[421], key[55],  key[287], key[173],
        key[419], key[21],  key[314], key[243], key[345], key[191], key[477], key[86],
        key[162], key[384], key[267], key[113], key[439], key[221], key[356], key[0]
    };

    assign sliced_key[7] = {
        key[471], key[140], key[323], key[254], key[393], key[67],  key[171], key[297],
        key[443], key[203], key[337], key[124], key[482], key[237], key[378], key[98],
        key[157], key[407], key[277], key[43],  key[367], key[454], key[310], key[189],
        key[223], key[489], key[100], key[423], key[269], key[342], key[138], key[467],
        key[372], key[246], key[183], key[502], key[294], key[449], key[71],  key[168],
        key[391], key[274], key[433], key[32],  key[149], key[327], key[465], key[230],
        key[357], key[192], key[413], key[88],  key[284], key[475], key[347], key[12],
        key[457], key[214], key[381], key[463], key[424], key[172], key[397], key[474]
    };

    assign sliced_key1 = sliced_key[0];
    assign sliced_key2 = sliced_key[1];
    assign sliced_key3 = sliced_key[2];
    assign sliced_key4 = sliced_key[3];
    assign sliced_key5 = sliced_key[4];
    assign sliced_key6 = sliced_key[5];
    assign sliced_key7 = sliced_key[6];
    assign sliced_key8 = sliced_key[7];

endmodule

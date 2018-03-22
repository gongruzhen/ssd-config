#!/usr/bin/python -u

dict_F1 = {
"name":"[G2IF1-2400GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":4,
"expluns":192,
"Tphylun":"0-47,64-111,128-175,192-239",
"ncodeword":5,
"nplane":2,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 2.4T, 8x8x4, toshiba 19nm 64GB"
}

dict_F2 = {
"name":"[G2IF2-3200GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":2,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":"24",
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 3.2T, 8x8x4, toshiba 19nm 64GB"
}

dict_F3 = {
"name":"[G2IF3-6400GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":1,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 6.4T, 8x8x4, toshiba A19nm 128GB"
}

dict_F6 = {
"name":"[G2IF6-3200GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":1,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 3.2T, 8x8x4, toshiba A19nm 64GB"
}

dict_F7 = {
"name":"[G2IF7-2400GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":"12",
"thread":8,
"lun":2,
"expluns":192,
"Tphylun":"0-191",
"ncodeword":5,
"nplane":1,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 2.4T, 12x8x2, toshiba A19nm 64GB"
}

dict_F8 = {
"name":"[G2IF8-6400GB]",
"flash_id":"2C A4 E5 3C A9 04 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":2,
"raidgroup":4,
"mbr_version":"0x5200",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 6.4T, 8x8x4, micron L85C 128G"
}

dict_F9 = {
"name":"[G2IF9-6400GB]",
"flash_id":"98 3C 95 93 7A D1 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":1,
"raidgroup":8,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 6.4T, 8x8x4, toshiba 15nm 128G"
}

dict_F10 = {
"name":"[G2IF10-6400GB]",
"flash_id":"45 3C 95 93 7A 51 0A 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":1,
"raidgroup":8,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 6.4T, 8x8x4, Sandisk 15nm 128G"
}

dict_F11 = {
"name":"[G2IF11-6400GB]",
"flash_id":"2C A4 E5 54 A9 00 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":2,
"raidgroup":8,
"mbr_version":"0x5200",
"power_budget":15,
"flash_ifclock":6,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 6.4T, 8x8x4, micron L95B 128G-12R"
}

dict_F12 = {
"name":"[G2IF12-6400GB]",
"flash_id":"2C A4 E5 54 A9 00 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":2,
"raidgroup":8,
"mbr_version":"0x5200",
"power_budget":15,
"flash_ifclock":5,
"burnin_ecc_limit":0,
"desc":"Naxos-FH 6.4T, 8x8x4, micron L95B 128G-6R:C"
}

dict_A1 = {
"name":"[G2IA1-1200GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":7,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-83,88-91,96-99,104-107",
"ncodeword":5,
"nplane":2,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Aruba 1.2T, 7x8x2, toshiba 19nm 64GB"
}

dict_A2 = {
"name":"[G2IA2-800GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":7,
"thread":8,
"lun":2,
"expluns":64,
"Tphylun":"0-19,24-27,32-35,40-43,48-51,56-59,64-67,72-75,80-83,88-91,96-99,104-107",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Aruba 800G, 7x8x2, toshiba 19nm 64GB"
}

dict_H1 = {
"name":"[G2IH1-1600GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":128,
"Tphylun":"0-127",
"ncodeword":5,
"nplane":2,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 1.6T, 8x8x2, toshiba 19nm 64GB"
}

dict_H2 = {
"name":"[G2IH2-800GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":64,
"Tphylun":"0-3,8-11,16-19,24-27,32-35,40-43,48-51,56-59,64-67,72-75,80-83,88-91,96-99,104-107,112-115,120-123",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 800G, 8x8x2, toshiba 19nm 64GB"
}

dict_H3 = {
"name":"[G2IH3-800GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":64,
"Tphylun":"0-3,8-11,16-19,24-27,32-35,40-43,48-51,56-59,64-67,72-75,80-83,88-91,96-99,104-107,112-115,120-123",
"ncodeword":5,
"nplane":1,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 800G, 8x8x2, toshiba A19nm 64GB"
}

dict_H4 = {
"name":"[G2IH4-1200GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-67,72-75,80-83,88-91,96-99,104-107,112-115,120-123",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 1200G, 8x8x2, toshiba A19nm 64GB"
}

dict_H5 = {
"name":"[G2IH5-1600GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":128,
"Tphylun":"0-127",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 1.6T, 8x8x2, toshiba A19nm 64GB"
}

dict_H6 = {
"name":"[G2IH6-3200GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":128,
"Tphylun":"0-127",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 3.2T, 8x8x2, toshiba A19nm 128GB"
}

dict_H7 = {
"name":"[G2IH7-800GB]",
"flash_id":"98 DE 94 93 76 D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":64,
"Tphylun":"0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126",
"ncodeword":5,
"nplane":1,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 800G, 8x8x2, toshiba A19nm 32GB"
}

dict_H8 = {
"name":"[G2IH8-2400GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-67,72-75,80-83,88-91,96-99,104-107,112-115,120-123",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 2.4T, 8x8x2, toshiba A19nm 128GB"
}

dict_H9 = {
"name":"[G2IH9-3200GB]",
"flash_id":"2C A4 E5 3C A9 04 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":8,
"thread":8,
"lun":2,
"expluns":128,
"Tphylun":"0-127",
"ncodeword":5,
"nplane":2,
"raidgroup":2,
"mbr_version":"0x5200",
"power_budget":"15",
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 3.2T, 8x8x2, micron L85C 128GB"
}

dict_H10 = {
"name":"[G2IH10-3200GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":112,
"Tphylun":"0-111",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH Lower OP 3.2T, 8x8x2, toshiba A19nm 128GB"
}

dict_H11 = {
"name":"[G2IH11-1200GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-47,64-111",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 1.2T, 8x8x2, toshiba A19nm 64GB"
}

dict_H12 = {
"name":"[G2IH12-2400GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-47,64-111",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 2.4T, 8x8x2, toshiba A19nm 128GB"
}

dict_H13 = {
"name":"[G2IH13-3200GB]",
"flash_id":"2C A4 E5 3C A9 04 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":8,
"thread":8,
"lun":2,
"expluns":112,
"Tphylun":"0-111",
"ncodeword":5,
"nplane":2,
"raidgroup":2,
"mbr_version":"0x5200",
"power_budget":15,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH Lower OP 3.2T, 8x8x2, micron L85C 128GB"
}

dict_H14 = {
"name":"[G2IH14-1600GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":112,
"Tphylun":"0-111",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH Lower OP 1.6T, 8x8x2, toshiba A19nm 64GB"
}

dict_H15 = {
"name":"[G2IH15-1600GB]",
"flash_id":"98 3A 94 93 76 D1 08 04",
"iowidth":16,
"ecc_tmode":58,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":64,
"Tphylun":"0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126",
"ncodeword":3,
"nplane":2,
"raidgroup":2,
"mbr_version":"0x5200",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 1.6T, 8x8x2, toshiba 15nm 64GB"
}

dict_H16 = {
"name":"[G2IH16-800GB]",
"flash_id":"98 3A 94 93 76 D1 08 04",
"iowidth":16,
"ecc_tmode":58,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":32,
"Tphylun":"0,2,8,10,16,18,24,26,32,34,40,42,48,50,56,58,64,66,72,74,80,82,88,90,96,98,104,106,112,114,120,122",
"ncodeword":3,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 800G, 8x8x2, toshiba 15nm 64GB"
}

dict_H17 = {
"name":"[G2IH17-3200GB]",
"flash_id":"98 3C 95 93 7A D1 08 04",
"iowidth":16,
"ecc_tmode":58,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":128,
"Tphylun":"0-127",
"ncodeword":3,
"nplane":1,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 3.2T, 8x8x2, toshiba 15nm 128GB"
}

dict_H18 = {
"name":"[G2IH18-3200GB]",
"flash_id":"2C A4 E5 54 A9 00 00 00",
"iowidth":16,
"ecc_tmode":58,
"ifmode":3,
"channel":8,
"thread":8,
"lun":2,
"expluns":128,
"Tphylun":"0-127",
"ncodeword":4,
"nplane":2,
"raidgroup":4,
"mbr_version":"0x5200",
"power_budget":15,
"flash_ifclock":5,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 3.2T, 8x8x2, micron L95B 16nm 128GB-6R:C"
}

dict_H19 = {
"name":"[G2IH19-3200GB]",
"flash_id":"2C A4 E5 54 A9 00 00 00",
"iowidth":16,
"ecc_tmode":58,
"ifmode":3,
"channel":8,
"thread":8,
"lun":2,
"expluns":128,
"Tphylun":"0-127",
"ncodeword":4,
"nplane":2,
"raidgroup":4,
"mbr_version":"0x5200",
"power_budget":15,
"flash_ifclock":6,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 3.2T, 8x8x2, micron L95B 16nm 128GB-12R"
}

dict_H20 = {
"name":"[G2IH20-3200GB]",
"flash_id":"45 3C 95 93 7A 51 0A 04",
"iowidth":16,
"ecc_tmode":58,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":128,
"Tphylun":"0-127",
"ncodeword":3,
"nplane":1,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 3.2T, 8x8x2, Sandisk 15nm 128GIR"
}

dict_H21 = {
"name":"[G2IH21-2400GB]",
"flash_id":"98 3C 95 93 7A D1 08 04",
"iowidth":16,
"ecc_tmode":58,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-47,64-111",
"ncodeword":3,
"nplane":1,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 2.4T, 8x8x2, toshiba 15nm 128GB"
}

dict_H22 = {
"name":"[G2IH22-3200GB]",
"flash_id":"45 3C 95 93 7A 51 0A 04",
"iowidth":16,
"ecc_tmode":58,
"ifmode":1,
"channel":8,
"thread":8,
"lun":2,
"expluns":112,
"Tphylun":"0-111",
"ncodeword":3,
"nplane":1,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH Lower OP 3.2T, 8x8x2, Sandisk 15nm 128GIR"
}

dict_H23 = {
"name":"[G2IH23-6400GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":8,
"thread":8,
"lun":4,
"expluns":256,
"Tphylun":"0-255",
"ncodeword":5,
"nplane":1,
"raidgroup":4,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Naxos-HH 6.4T, 8x8x4, toshiba A19nm 128GB"
}

dict_D0 = {
"name":"[G2ID0-1200GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-95",
"ncodeword":5,
"nplane":2,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Santa Cruz 8639 1.2T, 6x8x2, toshiba 19nm 64GB"
}

dict_D1 = {
"name":"[G2ID1-2400GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-95",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Santa Cruz 8639 2.4T, 6x8x2, toshiba A19nm 128GB"
}

dict_D2 = {
"name":"[G2ID2-1200GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-95",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Santa Cruz 8639 1.2T, 6x8x2, toshiba A19nm 64GB"
}

dict_S0 = {
"name":"[G2IS0-1200GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-95",
"ncodeword":5,
"nplane":2,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 1.2T, 6x8x2, toshiba 19nm 64GB"
}

dict_S1 = {
"name":"[G2IS1-800GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":64,
"Tphylun":"0-7,16-23,32-71,80-87",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 800G, 6x8x2, toshiba 19nm 64GB"
}

dict_S3 = {
"name":"[G2IS3-300GB]",
"flash_id":"89 88 24 4B A9 00 00 00",
"iowidth":16,
"ecc_tmode":16,
"ifmode":3,
"channel":6,
"thread":8,
"lun":2,
"expluns":24,
"Tphylun":"0,2,4,6,16,18,20,22,32,34,36,38,48,50,52,54,64,66,68,70,80,82,84,86",
"ncodeword":8,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 300G, 6x8x2, intel 25nm 32GB"
}

dict_S4 = {
"name":"[G2IS4-200GB]",
"flash_id":"89 88 24 4B A9 00 00 00",
"iowidth":16,
"ecc_tmode":16,
"ifmode":3,
"channel":6,
"thread":8,
"lun":2,
"expluns":16,
"Tphylun":"0,2,4,6,16,18,20,22,64,66,68,70,80,82,84,86",
"ncodeword":8,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 200G, 6x8x2, intel 25nm 32GB"
}

dict_S5 = {
"name":"[G2IS5-600GB]",
"flash_id":"2C 84 64 3C A5 00 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":6,
"thread":8,
"lun":2,
"expluns":24,
"Tphylun":"0,2,8,10,16,18,24,26,32,34,40,42,48,50,56,58,64,66,72,74,80,82,88,90",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5200",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 600G, 6x8x2, micron 20nm 32GB"
}

dict_S6 = {
"name":"[G2IS6-2400GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-95",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 2.4T, 6x8x2, toshiba A19nm 128GB"
}

dict_S7 = {
"name":"[G2IS7-400GB]",
"flash_id":"98 3A 95 93 7A D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":32,
"Tphylun":"0-7,16-23,64-71,80-87",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 400G, 6x8x2, toshiba 19nm 64GB"
}

dict_S8 = {
"name":"[G2IS8-600GB]",
"flash_id":"2C 64 64 3C A5 04 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":6,
"thread":8,
"lun":2,
"expluns":48,
"Tphylun":"0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5200",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 600G, 6x8x2, micron L84C 32GB"
}

dict_S9 = {
"name":"[G2IS9-1600GB]",
"flash_id":"98 3C A5 93 7E D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":64,
"Tphylun":"0-7,16-23,32-71,80-87",
"ncodeword":5,
"nplane":1,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 1.6T, 6x8x2, toshiba A19nm 128GB"
}

dict_S10 = {
"name":"[G2IS10-400GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":32,
"Tphylun":"0-7,16-23,64-71,80-87",
"ncodeword":5,
"nplane":1,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 400G, 6x8x2, toshiba A19nm 64GB"
}

dict_S11 = {
"name":"[G2IS11-800GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":64,
"Tphylun":"0-7,16-23,32-71,80-87",
"ncodeword":5,
"nplane":1,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 800G, 6x8x2, toshiba A19nm 64GB"
}

dict_S12 = {
"name":"[G2IS12-1500GB]",
"flash_id":"2C A4 E5 3C A9 04 00 00 and 2C 84 64 3C A5 00 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":6,
"thread":8,
"lun":2,
"expluns":56,
"Tphylun":"0-7,16-23,24,26,32-39,40,42,48-55,56,58,64-71,72,74,80-87",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5200",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 1.5T, 6x8x2, micron L85A 32G and L85C 128G"
}

dict_S13 = {
"name":"[G2IS13-1500GB]",
"flash_id":"2C A4 E5 3C A9 04 00 00 and 2C 84 64 3C A9 04 00 00",
"iowidth":16,
"ecc_tmode":35,
"ifmode":3,
"channel":6,
"thread":8,
"lun":2,
"expluns":56,
"Tphylun":"0-7,16-23,24,26,32-39,40,42,48-55,56,58,64-71,72,74,80-87",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5200",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 1.5T, 6x8x2, micron L85C 32G and L85C 128G"
}

dict_S14 = {
"name":"[G2IS14-300GB]",
"flash_id":"98 DE 94 93 76 D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":24,
"Tphylun":"0,2,4,6,16,18,20,22,32,34,36,38,48,50,52,54,64,66,68,70,80,82,84,86",
"ncodeword":5,
"nplane":1,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 300G, 6x8x2, toshiba A19nm 32GB"
}

dict_S15 = {
"name":"[G2IS15-400GB]",
"flash_id":"98 DE 94 93 76 D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":32,
"Tphylun":"0,2,4,6,16,18,20,22,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,80,82,84,86",
"ncodeword":5,
"nplane":1,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 400G, 6x8x2, toshiba A19nm 32GB"
}

dict_S16 = {
"name":"[G2IS16-1200GB]",
"flash_id":"98 3A 95 93 7A D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":96,
"Tphylun":"0-95",
"ncodeword":5,
"nplane":1,
"raidgroup":2,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 1.2T, 6x8x2, toshiba A19nm 64GB"
}

dict_S17 = {
"name":"[G2IS17-400GB]",
"flash_id":"98 DE 94 93 76 D7 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":32,
"Tphylun":"0,2,4,6,16,18,20,22,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,80,82,84,86",
"ncodeword":5,
"nplane":2,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 400G, 6x8x2, toshiba 19nm 32GB"
}

dict_S18 = {
"name":"[G2IS18-600GB]",
"flash_id":"98 DE 94 93 76 D0 08 04",
"iowidth":16,
"ecc_tmode":35,
"ifmode":1,
"channel":6,
"thread":8,
"lun":2,
"expluns":48,
"Tphylun":"0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94",
"ncodeword":5,
"nplane":1,
"raidgroup":1,
"mbr_version":"0x5100",
"power_budget":24,
"flash_ifclock":0,
"burnin_ecc_limit":0,
"desc":"Fiji 600G, 6x8x2, toshiba A19nm 32GB"
}


dict_list1 = []
dict_list2 = []
dict_list3 = []
dict_list4 = []
dict_list5 = []
dict_list6 = []
dict_list7 = []



#8x8x4 35
dict_list1.append(dict_F1)
dict_list1.append(dict_F2)
dict_list1.append(dict_F3)
dict_list1.append(dict_F6)
dict_list1.append(dict_F8)
dict_list1.append(dict_F9)
dict_list1.append(dict_F10)
dict_list1.append(dict_F11)
dict_list1.append(dict_F12)

dict_list1.append(dict_H23)



#12x8x2 35
dict_list2.append(dict_F7)



#7x8x2 35
dict_list3.append(dict_A1)
dict_list3.append(dict_A2)



#8x8x2 35
dict_list4.append(dict_H1)
dict_list4.append(dict_H2)
dict_list4.append(dict_H3)
dict_list4.append(dict_H4)
dict_list4.append(dict_H5)
dict_list4.append(dict_H6)
dict_list4.append(dict_H7)
dict_list4.append(dict_H8)
dict_list4.append(dict_H9)
dict_list4.append(dict_H10)
dict_list4.append(dict_H11)
dict_list4.append(dict_H12)
dict_list4.append(dict_H13)
dict_list4.append(dict_H14)



#8x8x2 58
dict_list5.append(dict_H15)
dict_list5.append(dict_H16)
dict_list5.append(dict_H17)
dict_list5.append(dict_H18)
dict_list5.append(dict_H19)
dict_list5.append(dict_H20)
dict_list5.append(dict_H21)
dict_list5.append(dict_H22)



#6x8x2 35
dict_list6.append(dict_D0)
dict_list6.append(dict_D1)
dict_list6.append(dict_D2)

dict_list6.append(dict_S0)
dict_list6.append(dict_S1)
dict_list6.append(dict_S5)
dict_list6.append(dict_S6)
dict_list6.append(dict_S7)
dict_list6.append(dict_S8)
dict_list6.append(dict_S9)
dict_list6.append(dict_S10)
dict_list6.append(dict_S11)
dict_list6.append(dict_S12)
dict_list6.append(dict_S13)
dict_list6.append(dict_S14)
dict_list6.append(dict_S15)
dict_list6.append(dict_S16)
dict_list6.append(dict_S17)
dict_list6.append(dict_S18)



#6x8x2 16
dict_list7.append(dict_S3)
dict_list7.append(dict_S4)



dictall = {
"HW_nchannel8HW_nthread8HW_nlun4HW_ecc_tmode35": dict_list1,
"HW_nchannel12HW_nthread8HW_nlun2HW_ecc_tmode35": dict_list2,
"HW_nchannel7HW_nthread8HW_nlun2HW_ecc_tmode35": dict_list3,
"HW_nchannel8HW_nthread8HW_nlun2HW_ecc_tmode35": dict_list4,
"HW_nchannel8HW_nthread8HW_nlun2HW_ecc_tmode58": dict_list5,
"HW_nchannel6HW_nthread8HW_nlun2HW_ecc_tmode35": dict_list6,
"HW_nchannel6HW_nthread8HW_nlun2HW_ecc_tmode16": dict_list7
}




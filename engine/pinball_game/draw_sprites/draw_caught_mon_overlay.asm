DrawCaughtMonOverlay:
; In Catch 'Em mode, if the wild mon is already owned in the pokedex, overlays the
; pokeball icon from the number of balls left onto the lower right of the
; billboard portrait, slightly inset from its border.
	ld a, [wInSpecialMode]
	and a
	ret z
	ld a, [wSpecialMode]
	and a ; SPECIAL_MODE_CATCHEM
	ret nz
	ld a, [wCapturingMon]
	and a
	ret nz
	ld a, [wWildMonIsHittable] ; portrait is replaced by the animated mon sprite
	and a
	ret nz
	ld a, [wCurrentCatchEmMon]
	ld b, a
	ld a, [wCurrentCatchEmMon + 1]
	ld c, a
	ld hl, wPokedexFlags
	add hl, bc
	bit 1, [hl] ; owned flag, see SetPokemonOwnedFlag
	ret z
	ld a, $66
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $44
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, $97 ; OAMData2_CaughtOverlay
	call LoadOAMData2
	ret

LoadCaughtOverlayBallGfx:
; Loads the overlay graphic into VRAM while the LCD is on.
	ld a, BANK(CaughtOverlayBallGfx)
	ld hl, CaughtOverlayBallGfx
	ld de, vTilesOB tile $3a
	ld bc, $0020
	call LoadVRAMData
	ldh a, [hGameBoyColorFlag]
	and a
	ret z
	ld a, BANK(PokeBallObjPalette)
	ld hl, PokeBallObjPalette ; always red and white, regardless of the current ball type
	ld de, $0070 ; OBJ palette 6
	ld bc, $0008
	call Func_7dc
	ret

LoadCaughtOverlayBallGfx_DuringLoadStage:
; Same as above, for when the stage is being loaded with the LCD off.
	ld a, BANK(CaughtOverlayBallGfx)
	ld hl, CaughtOverlayBallGfx
	ld de, vTilesOB tile $3a
	ld bc, $0020
	call FarCopyData
	ldh a, [hGameBoyColorFlag]
	and a
	ret z
	ld a, BANK(PokeBallObjPalette)
	ld hl, PokeBallObjPalette
	ld de, $0070
	ld bc, $0008
	call FarCopyCGBPals
	ret

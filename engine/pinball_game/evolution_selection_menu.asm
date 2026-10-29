MoveEvolutionSelectionCursor:
	ld a, [wPressedButtonsPersistent]
	ld b, a
	ld a, [wNumPartyMons]
	ld c, a
	ld a, [wCurSelectedPartyMon]
	bit BIT_D_UP, b
	jr z, .didntPressUp
	and a
	ret z
	; move the cursor up
	dec a
	ld [wCurSelectedPartyMon], a
	lb de, $00, $03
	call PlaySoundEffect
	ret

.didntPressUp
	bit BIT_D_DOWN, b
	ret z
	inc a
	cp c
	ret z
	; move the cursor down
	ld [wCurSelectedPartyMon], a
	lb de, $00, $03
	call PlaySoundEffect
	ret

AreAllEvolutionsOwned:
; Sets the carry flag if the pokemon has at least one evolution, and all of its
; evolutions are already owned in the pokedex. Breeding doesn't count as an evolution.
; Input: de = pokemon id (big endian)
; Preserves bc, since the caller uses c as the list row.
	push bc
	call .check
	pop bc ; doesn't affect the carry flag
	ret

.check
	ld h, d
	ld l, e
	add hl, hl
	ld bc, MonEvolutions
	add hl, bc
	ld a, Bank(MonEvolutions)
	call ReadByteFromBank
	ld c, a
	inc hl
	ld a, Bank(MonEvolutions)
	call ReadByteFromBank
	ld h, a
	ld l, c ; hl points to the mon's evolution data
	ld a, Bank(MonEvolutions)
	call ReadByteFromBank
	and a
	jr z, .notAllOwned
	ld b, a ; b = number of evolutions
	ld c, $0 ; c = set once a non-breeding evolution is found
	inc hl
.loop
	ld a, Bank(MonEvolutions)
	call ReadByteFromBank
	ld e, a
	inc hl
	ld a, Bank(MonEvolutions)
	call ReadByteFromBank
	ld d, a
	inc hl
	ld a, Bank(MonEvolutions)
	call ReadByteFromBank
	inc hl
	cp EVO_BREEDING
	jr z, .next
	push hl
	dec de ; evolution entries hold the pokemon id + 1
	ld hl, wPokedexFlags
	add hl, de
	bit 1, [hl] ; owned flag, see SetPokemonOwnedFlag
	pop hl
	jr z, .notAllOwned
	inc c
.next
	dec b
	jr nz, .loop
	ld a, c
	and a
	jr z, .notAllOwned
	scf
	ret

.notAllOwned
	and a
	ret

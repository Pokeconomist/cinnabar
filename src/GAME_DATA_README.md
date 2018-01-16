# Game Data Handling

## Format of deck hash

The `DECK` variable stores the complete deck information, is an array of sets (with attributes `set_num` and `set_data`, which is comprised of `set_name`, and `set_cards`). `set_cards` is an array of cards (with attributes `set_pos` and `card_data`, comprised of `card_name` and `card_desc`).

It is structured as follows;

```
[
  :set_num => $int,
  :set_data => {
    :set_name => $str,
    :set_len => $int,
    :set_cards => [
      :set_pos => $str,
      :card_data => {
        :card_name => $str,
        :card_desc => $str,
      ],
      ...
    },
  },
  ...
]
```




## Handling of Turn Data

The `turn_data` variable specifies what occurred during the last turn, and is used to notify other players of previous actions.

It is constructed as follows;

`turn_data = [{:card_taken => $bool, :called_player_num => $int, :calling_player_num => $int, :card => $ary}, ...]`

Where `card_taken = true` if the called player has the called card, and `card` is the card id.

All calling results can be contained within these variables as follows

ie.

```
:CALL
if (CALLED_PLAYER has CALLED_CARD) {
  WRITE to turn_data & GOTO CALL
} else {
  WRITE to turn_data & GOTO END_TURN
}
:END_TURN

```
Thus `turn_data[-1][:card_taken] == false` for all end of turn cases, however doesn't not necessitate and end of turn (due to rules if `called_card == drawn_card)`


## Handling of Completed Set Data

The `complete_sets` variable stores completed sets, and is used to notify other players.

It is constructed as follows;

`complete_sets = [{:set_num => $int, :player_num => $int, :crown_cards => $ary}, ...]`

Where `crown_cards` is an array of crown set cards used to complete the set, `nil` if none used.
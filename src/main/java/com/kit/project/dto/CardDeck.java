package com.kit.project.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CardDeck {
 private String player;
 private int score;
 private Fungus fungus;
}

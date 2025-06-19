package com.kit.project.config;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.kit.project.dto.MessagePayLoads.PlayerAction;
import com.kit.project.dto.MessagePayLoads.PlayerJoinRequest;
import com.kit.project.dto.MessagePayLoads.ScoreMessage;
import com.kit.project.dto.MessagePayLoads.TurnMessage;

@Controller
public class TurnController {

    private final SimpMessagingTemplate template;
    private List<String> players = new ArrayList<>();
    private Map<String, Integer> scoreMap = new HashMap<>();
    private int currentTurn = 0;

    public TurnController(SimpMessagingTemplate template) {
        this.template = template;
    }

    @MessageMapping("/join")
    public void join(PlayerJoinRequest req) {
        if (!players.contains(req.getNickname())) {
            players.add(req.getNickname());
            scoreMap.put(req.getNickname(), 0);
        }
        template.convertAndSend("/topic/turn", new TurnMessage(players.get(currentTurn)));
    }

    @MessageMapping("/endTurn")
    public void endTurn(PlayerAction action) {
        currentTurn = (currentTurn + 1) % players.size();
        template.convertAndSend("/topic/turn", new TurnMessage(players.get(currentTurn)));
    }

    @MessageMapping("/updateScore")
    public void updateScore(ScoreMessage score) {
        scoreMap.put(score.getNickname(), score.getScore());
        template.convertAndSend("/topic/score", score);
    }
}
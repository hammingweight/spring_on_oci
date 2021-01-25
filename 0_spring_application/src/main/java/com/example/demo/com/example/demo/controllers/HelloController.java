package com.example.demo.com.example.demo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping(path = "/hello", produces = "application/json")
public class HelloController {

    @Autowired
    public JdbcTemplate jdbc;

    @GetMapping("/{name}")
    public Map<String, String> sayHello(@PathVariable("name") String name) {
        jdbc.update("INSERT INTO person (name, num_visits) VALUES(?, 1)", name);
        //jdbc.queryForObject("select ")
        Map<String, String> map = new HashMap<>();
        map.put("message", "Hello, " + name);
        map.put("jdbc_ok", jdbc != null ? "yes": "no");
        return map;
    }

}

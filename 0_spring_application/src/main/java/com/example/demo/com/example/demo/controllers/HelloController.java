package com.example.demo.com.example.demo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(path = "/hello", produces = "application/json")
public class HelloController {

    @Autowired
    public JdbcTemplate jdbcTemplate;

    @GetMapping("/{name}")
    public Map<String, String> sayHello(@PathVariable("name") String name) {
        String sqlQuery = "SELECT num_visits FROM person WHERE name=?";
        List<Integer>  numVisits = jdbcTemplate.query(sqlQuery, new SingleColumnRowMapper<>(), name);
        Map<String, String> map = new HashMap<>();
        if (numVisits.size() == 0) {
            jdbcTemplate.update("INSERT INTO person (name, num_visits) VALUES (?, 1)", name);
            map.put("First timer", "yes");
        } else {
            map.put("First timer", "no");
        }
        return map;
    }

}

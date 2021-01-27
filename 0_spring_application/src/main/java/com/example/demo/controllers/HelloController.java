package com.example.demo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * A REST controller that listens for GET requests to the /hello and /hello/{name} endpoints.
 * The response returns a greeting and a count of how many times the endpoint has been queried.
 */
@RestController
@RequestMapping(path = "/hello", produces = "application/json")
public class HelloController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping()
    public Map<String, Object> sayHello() {
        return sayHello("world");
    }

    @Transactional
    @GetMapping("/{name}")
    public Map<String, Object> sayHello(@PathVariable("name") String name) {
        // SELECT ... FOR UPDATE so that we can lock the row to prevent concurrent modifications.
        String sqlQuery = "SELECT num_visits FROM visitors WHERE name=? FOR UPDATE";
        List<BigDecimal>  numVisits = jdbcTemplate.query(sqlQuery, new SingleColumnRowMapper<>(), name);
        Map<String, Object> map = new HashMap<>();
        if (numVisits.size() == 0) {
            String sqlInsert = "INSERT INTO visitors (name, num_visits) VALUES (?, 1)";
            jdbcTemplate.update(sqlInsert, name);
            map.put("message", "Hello, " + name);
            map.put("visits", 1);
        } else {
            BigDecimal count = numVisits.get(0).add(BigDecimal.ONE);
            String sqlUpdate = "UPDATE visitors SET num_visits=? WHERE name=?";
            jdbcTemplate.update(sqlUpdate, count, name);
            map.put("message", "Hello again, " + name);
            map.put("visits", count);
        }
        return map;
    }
}

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

@RestController
@RequestMapping(path = "/hello", produces = "application/json")
public class HelloController {

    @Autowired
    public JdbcTemplate jdbcTemplate;

    @Transactional
    @GetMapping("/{name}")
    public Map<String, Object> sayHello(@PathVariable("name") String name) throws Throwable {
        String sqlQuery = "SELECT num_visits FROM person WHERE name=?";
        List<BigDecimal>  numVisits = jdbcTemplate.query(sqlQuery, new SingleColumnRowMapper<>(), name);
	Thread.sleep(6000);
        Map<String, Object> map = new HashMap<>();
        if (numVisits.size() == 0) {
            // SELECT ... FOR UPDATE so that we can lock the row to prevent concurrent
            // modifications.
            String sqlInsert = "INSERT INTO person (name, num_visits) VALUES (?, 1) FOR UPDATE";
            jdbcTemplate.update(sqlInsert, name);
            map.put("message", "Hello, " + name);
            map.put("visits", 1);
        } else {
            BigDecimal count = numVisits.get(0).add(BigDecimal.ONE);
            String sqlUpdate = "UPDATE person SET num_visits=? WHERE name=?";
            jdbcTemplate.update(sqlUpdate, count, name);
            map.put("message", "Hello again, " + name);
            map.put("visits", count);
        }
        return map;
    }
}

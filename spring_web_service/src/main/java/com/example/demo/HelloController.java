package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping(path = "/hello", produces = "application/json")
public class HelloController {

    @GetMapping("/{name}")
    public Map<String, String> sayHello(@PathVariable("name") String name) {
        Map<String, String> map = new HashMap<>();
        map.put("message", "Hello, " + name);
        return map;
    }
}

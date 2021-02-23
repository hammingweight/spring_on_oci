package com.example.demo.models;

import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

@JsonPropertyOrder({ "visits", "message" })
public class VisitorGreeting {

    private String message;

    private int numberOfVisits;

    public void setMessage(String message) {
        this.message = message;
    }

    public void setNumberOfVisits(int numberOfVisits) {
        this.numberOfVisits = numberOfVisits;
    }

    public String getMessage() {
        return message;
    }

    @JsonGetter("visits")
    public int getNumberOfVisits() {
        return numberOfVisits;
    }
}

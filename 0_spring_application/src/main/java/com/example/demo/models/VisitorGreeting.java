package com.example.demo.models;

import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

/**
 * A model of a greeting for a visitor to a REST
 * endpoint. The object contains a message and an
 * invocation count.
 */
@JsonPropertyOrder({ "visits", "message" })
public class VisitorGreeting {

    // A message to display.
    private String message;

    // How many times has an endpoint been invoked.
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

package com.example.rest_api_demo.model;

public class Greeting {
        private long id;
        private String message;

        public Greeting(long id, String message) {
            this.id = id;
            this.message = message;
        }

        public long getId() {
            return id;
        }

        public String getMessage() {
            return message;
        }
}

```mermaid
erDiagram
    performances {
        UUID id PK
        text title 
        date held_date 
        text theme 
        UUID conference_id FK
    }

    conferences {
        UUID id PK
        date held_date 
        text address 
    }
    participants {
        UUID id PK
        text first_name 
        text last_name 
        date birth_date
    }
    ConferencesParticipants {
        UUID conference_id FK
        UUID participant_id FK
    }
    conferences ||--o{ ConferencesParticipants : ""
    ConferencesParticipants }o--|| participants : ""
    conferences |o{ performances : ""
```

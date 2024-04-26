```mermaid
erDiagram
    performances {
        UUID id PK
        title text
        held_date date
        theme text
        conference_id FK
    }
    conferences {
        UUID id PK
        held_date date
        address text
    }
    participants {
        UUID id PK
        first_name text
        last_name text
        birth_date date
    }
    ConferencesParticipants {
        UUID conference_id FK
        UUID participant_id FK
    }
    conferences ||--o{ ConferencesParticipants : ""
    ConferencesParticipants }o--|| participants : ""
    conferences ||--o{ performances : ""
```

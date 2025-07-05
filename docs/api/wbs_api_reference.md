# Work Breakdown Structure (WBS) API Reference

The WBS API provides comprehensive management of Work Breakdown Structure tasks for solar PV installation projects. This implementation follows the detailed Solar PV WBS Implementation Plan and supports the complete project lifecycle from initiation to closure.

## Overview

The WBS API allows for:
- Hierarchical task management with parent-child relationships
- Task dependency tracking (prerequisite relationships)
- Progress monitoring and reporting
- Evidence attachment (photos, documents)
- Status updates and workflow management
- Project progress calculation based on weighted task completion

## Authentication

All WBS endpoints require JWT authentication:

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

### Role-Based Access Control

| Role | Permissions |
|------|-------------|
| Admin | Full CRUD access to all WBS tasks |
| Manager | Full CRUD access to WBS tasks in assigned projects |
| User | Read access to assigned tasks, can update task status and add evidence |
| Viewer | Read-only access to WBS tasks |

## Base URL

```
https://api.solar-management.com/api/v1/wbs
```

## Data Models

### WBS Task

```json
{
  "id": "string",
  "wbs_code": "string",
  "task_name": "string",
  "description": "string",
  "project_id": "string",
  "parent_task_id": "string|null",
  "task_type": "phase|deliverable|work_package|activity",
  "status": "not_started|in_progress|completed|blocked|cancelled",
  "priority": "low|medium|high|critical",
  "start_date": "datetime",
  "end_date": "datetime",
  "estimated_duration": "integer",
  "actual_duration": "integer|null",
  "progress_percentage": "integer",
  "weight": "float",
  "assigned_to": "string|null",
  "assigned_team": "string|null",
  "estimated_cost": "float|null",
  "actual_cost": "float|null",
  "deliverables": ["string"],
  "acceptance_criteria": ["string"],
  "dependencies": ["string"],
  "materials_required": ["string"],
  "equipment_required": ["string"],
  "safety_requirements": ["string"],
  "quality_standards": ["string"],
  "evidence_required": ["string"],
  "evidence_attachments": ["attachment_object"],
  "notes": "string|null",
  "created_at": "datetime",
  "updated_at": "datetime",
  "completed_at": "datetime|null",
  "children": ["wbs_task_object"]
}
```

### Attachment Object

```json
{
  "id": "string",
  "filename": "string",
  "file_type": "image|document|video",
  "file_size": "integer",
  "url": "string",
  "thumbnail_url": "string|null",
  "uploaded_by": "string",
  "uploaded_at": "datetime",
  "description": "string|null"
}
```

### Progress Summary

```json
{
  "project_id": "string",
  "overall_progress": "float",
  "phase_progress": {
    "initiation": "float",
    "planning": "float",
    "execution": "float",
    "monitoring": "float",
    "closure": "float"
  },
  "tasks_summary": {
    "total_tasks": "integer",
    "completed_tasks": "integer",
    "in_progress_tasks": "integer",
    "not_started_tasks": "integer",
    "blocked_tasks": "integer"
  },
  "schedule_performance": {
    "on_schedule": "integer",
    "behind_schedule": "integer",
    "ahead_schedule": "integer"
  },
  "cost_performance": {
    "estimated_total": "float",
    "actual_spent": "float",
    "variance": "float"
  }
}
```

## Endpoints

### 1. Get Project WBS

Get the complete Work Breakdown Structure for a project.

```http
GET /projects/{project_id}/wbs
```

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `level` | integer | Maximum hierarchy level to return (default: all) |
| `status` | string | Filter by task status |
| `assigned_to` | string | Filter by assignee |
| `include_children` | boolean | Include child tasks (default: true) |
| `include_evidence` | boolean | Include evidence attachments (default: false) |

#### Response

```json
{
  "success": true,
  "data": {
    "project_id": "proj_123",
    "wbs_structure": [
      {
        "id": "wbs_001",
        "wbs_code": "1.0",
        "task_name": "Project Initiation",
        "task_type": "phase",
        "status": "completed",
        "progress_percentage": 100,
        "children": [
          {
            "id": "wbs_002",
            "wbs_code": "1.1",
            "task_name": "Site Assessment",
            "task_type": "deliverable",
            "status": "completed",
            "progress_percentage": 100
          }
        ]
      }
    ],
    "summary": {
      "total_tasks": 45,
      "completed_tasks": 12,
      "overall_progress": 26.7
    }
  }
}
```

### 2. Get WBS Task Details

Get detailed information about a specific WBS task.

```http
GET /tasks/{task_id}
```

#### Response

```json
{
  "success": true,
  "data": {
    "id": "wbs_001",
    "wbs_code": "2.3.1",
    "task_name": "Roof Structure Assessment",
    "description": "Evaluate roof condition and structural integrity",
    "project_id": "proj_123",
    "parent_task_id": "wbs_parent",
    "task_type": "work_package",
    "status": "in_progress",
    "priority": "high",
    "start_date": "2025-01-15T08:00:00Z",
    "end_date": "2025-01-17T17:00:00Z",
    "estimated_duration": 16,
    "progress_percentage": 60,
    "weight": 0.05,
    "assigned_to": "tech_001",
    "assigned_team": "Assessment Team",
    "deliverables": [
      "Structural assessment report",
      "Load calculation documentation",
      "Photo documentation"
    ],
    "acceptance_criteria": [
      "Roof structure can support 2.5 kN/m² additional load",
      "No structural defects identified",
      "All safety requirements documented"
    ],
    "dependencies": ["wbs_site_survey"],
    "materials_required": [
      "Load testing equipment",
      "Measuring tools",
      "Safety equipment"
    ],
    "safety_requirements": [
      "Fall protection required",
      "Roof access safety protocols",
      "Emergency procedures briefing"
    ],
    "evidence_required": [
      "Before photos",
      "Load test results",
      "Structural report"
    ],
    "evidence_attachments": [
      {
        "id": "att_001",
        "filename": "roof_assessment_photos.jpg",
        "file_type": "image",
        "url": "https://storage.example.com/evidence/att_001.jpg",
        "uploaded_by": "tech_001",
        "uploaded_at": "2025-01-15T14:30:00Z"
      }
    ]
  }
}
```

### 3. Create WBS Task

Create a new task in the Work Breakdown Structure.

```http
POST /projects/{project_id}/wbs/tasks
```

#### Request Body

```json
{
  "wbs_code": "3.2.4",
  "task_name": "Panel Installation - Section A",
  "description": "Install solar panels on the eastern roof section",
  "parent_task_id": "wbs_parent_123",
  "task_type": "work_package",
  "priority": "high",
  "start_date": "2025-02-01T08:00:00Z",
  "end_date": "2025-02-03T17:00:00Z",
  "estimated_duration": 24,
  "weight": 0.08,
  "assigned_to": "installer_001",
  "assigned_team": "Installation Team A",
  "estimated_cost": 15000,
  "deliverables": [
    "Installed solar panels",
    "Electrical connections completed",
    "Quality inspection passed"
  ],
  "acceptance_criteria": [
    "All panels properly mounted and aligned",
    "Electrical connections tested and verified",
    "No damage to roof structure"
  ],
  "dependencies": ["wbs_mounting_system"],
  "materials_required": [
    "Solar panels (20 units)",
    "Mounting clamps",
    "MC4 connectors",
    "DC cables"
  ],
  "equipment_required": [
    "Drill with bits",
    "Torque wrench",
    "Multimeter",
    "Safety equipment"
  ],
  "safety_requirements": [
    "Fall protection system",
    "Electrical safety protocols",
    "Tool inspection checklist"
  ],
  "quality_standards": [
    "IEC 61215 compliance",
    "Local electrical codes",
    "Manufacturer installation guidelines"
  ],
  "evidence_required": [
    "Installation photos",
    "Electrical test results",
    "Quality checklist"
  ]
}
```

#### Response

```json
{
  "success": true,
  "data": {
    "id": "wbs_new_001",
    "wbs_code": "3.2.4",
    "task_name": "Panel Installation - Section A",
    "status": "not_started",
    "progress_percentage": 0,
    "created_at": "2025-01-10T10:00:00Z"
  },
  "message": "WBS task created successfully"
}
```

### 4. Update WBS Task

Update an existing WBS task.

```http
PUT /tasks/{task_id}
```

#### Request Body

```json
{
  "status": "in_progress",
  "progress_percentage": 45,
  "actual_duration": 18,
  "actual_cost": 12500,
  "notes": "Installation proceeding as planned. Weather conditions favorable."
}
```

#### Response

```json
{
  "success": true,
  "data": {
    "id": "wbs_001",
    "updated_fields": ["status", "progress_percentage", "actual_duration", "actual_cost", "notes"],
    "updated_at": "2025-01-15T14:30:00Z"
  },
  "message": "WBS task updated successfully"
}
```

### 5. Update Task Status

Update only the status of a WBS task.

```http
PATCH /tasks/{task_id}/status
```

#### Request Body

```json
{
  "status": "completed",
  "completion_notes": "All panels installed and tested successfully",
  "completed_by": "installer_001"
}
```

#### Response

```json
{
  "success": true,
  "data": {
    "id": "wbs_001",
    "status": "completed",
    "progress_percentage": 100,
    "completed_at": "2025-02-03T16:45:00Z",
    "completed_by": "installer_001"
  },
  "message": "Task status updated successfully"
}
```

### 6. Upload Evidence

Upload evidence files for a WBS task.

```http
POST /tasks/{task_id}/evidence
```

#### Request (Multipart Form Data)

```
file: [binary file data]
description: "Final installation photos showing completed panel array"
evidence_type: "completion_photo"
```

#### Response

```json
{
  "success": true,
  "data": {
    "attachment_id": "att_new_001",
    "filename": "panel_installation_final.jpg",
    "file_type": "image",
    "file_size": 2048576,
    "url": "https://storage.example.com/evidence/att_new_001.jpg",
    "thumbnail_url": "https://storage.example.com/evidence/thumbs/att_new_001_thumb.jpg",
    "uploaded_at": "2025-02-03T16:50:00Z"
  },
  "message": "Evidence uploaded successfully"
}
```

### 7. Get Project Progress

Get comprehensive progress information for a project.

```http
GET /projects/{project_id}/progress
```

#### Response

```json
{
  "success": true,
  "data": {
    "project_id": "proj_123",
    "overall_progress": 34.5,
    "phase_progress": {
      "initiation": 100.0,
      "planning": 85.0,
      "execution": 25.0,
      "monitoring": 20.0,
      "closure": 0.0
    },
    "tasks_summary": {
      "total_tasks": 48,
      "completed_tasks": 15,
      "in_progress_tasks": 8,
      "not_started_tasks": 23,
      "blocked_tasks": 2
    },
    "schedule_performance": {
      "on_schedule": 35,
      "behind_schedule": 8,
      "ahead_schedule": 5
    },
    "cost_performance": {
      "estimated_total": 125000.00,
      "actual_spent": 42500.00,
      "variance": -2500.00,
      "variance_percentage": -5.9
    },
    "critical_path": [
      {
        "task_id": "wbs_critical_001",
        "task_name": "Electrical Interconnection",
        "status": "in_progress",
        "days_behind": 2
      }
    ],
    "upcoming_milestones": [
      {
        "task_id": "wbs_milestone_001",
        "task_name": "System Commissioning",
        "due_date": "2025-02-15T17:00:00Z",
        "days_until_due": 8
      }
    ]
  }
}
```

### 8. Get Task Dependencies

Get dependency information for a specific task.

```http
GET /tasks/{task_id}/dependencies
```

#### Response

```json
{
  "success": true,
  "data": {
    "task_id": "wbs_001",
    "prerequisites": [
      {
        "id": "wbs_prereq_001",
        "task_name": "Structural Assessment",
        "status": "completed",
        "completion_date": "2025-01-10T17:00:00Z"
      },
      {
        "id": "wbs_prereq_002",
        "task_name": "Permit Approval",
        "status": "in_progress",
        "expected_completion": "2025-01-20T17:00:00Z"
      }
    ],
    "dependents": [
      {
        "id": "wbs_dependent_001",
        "task_name": "Panel Installation",
        "status": "not_started",
        "blocked_by_current": true
      }
    ],
    "can_start": false,
    "blocking_reason": "Waiting for permit approval completion"
  }
}
```

### 9. Delete WBS Task

Delete a WBS task (only if no dependencies exist).

```http
DELETE /tasks/{task_id}
```

#### Response

```json
{
  "success": true,
  "message": "WBS task deleted successfully"
}
```

### 10. Bulk Update Tasks

Update multiple tasks in a single request.

```http
PATCH /projects/{project_id}/wbs/bulk-update
```

#### Request Body

```json
{
  "updates": [
    {
      "task_id": "wbs_001",
      "progress_percentage": 75,
      "status": "in_progress"
    },
    {
      "task_id": "wbs_002",
      "progress_percentage": 100,
      "status": "completed",
      "completed_at": "2025-01-15T17:00:00Z"
    }
  ]
}
```

#### Response

```json
{
  "success": true,
  "data": {
    "updated_tasks": 2,
    "failed_updates": 0,
    "details": [
      {
        "task_id": "wbs_001",
        "status": "updated"
      },
      {
        "task_id": "wbs_002",
        "status": "updated"
      }
    ]
  },
  "message": "Bulk update completed successfully"
}
```

## Task Types

### 1. Phase
High-level project phases (Initiation, Planning, Execution, Monitoring, Closure)

### 2. Deliverable
Major project deliverables or outcomes

### 3. Work Package
Specific work items that can be assigned and tracked

### 4. Activity
Detailed activities within work packages

## Task Status Flow

```
not_started → in_progress → completed
     ↓            ↓            ↑
   blocked ←  cancelled    [can reopen]
```

## Priority Levels

- **Critical**: Tasks that block project completion
- **High**: Important tasks with tight deadlines
- **Medium**: Standard priority tasks
- **Low**: Tasks that can be delayed if necessary

## Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 400 | Invalid WBS code format | WBS code doesn't follow numbering convention |
| 403 | Insufficient permissions | User lacks required permissions |
| 404 | Task not found | Specified task ID doesn't exist |
| 409 | Dependency conflict | Cannot complete due to unresolved dependencies |
| 422 | Invalid task hierarchy | Parent-child relationship would create a cycle |
| 500 | Server error | Internal server error |

## Rate Limiting

API requests are limited to:
- 100 requests per minute for read operations
- 30 requests per minute for write operations
- 10 requests per minute for file uploads

## Webhooks

The WBS API supports webhooks for real-time notifications:

### Available Events

- `task.created`
- `task.updated`
- `task.status_changed`
- `task.completed`
- `evidence.uploaded`
- `project.progress_updated`

### Webhook Payload Example

```json
{
  "event": "task.completed",
  "timestamp": "2025-01-15T17:00:00Z",
  "data": {
    "task_id": "wbs_001",
    "project_id": "proj_123",
    "task_name": "Panel Installation",
    "completed_by": "installer_001",
    "completion_time": "2025-01-15T16:45:00Z"
  }
}
```

## Best Practices

### 1. WBS Code Structure
Follow hierarchical numbering: `1.0`, `1.1`, `1.1.1`, `1.1.2`, `1.2`, etc.

### 2. Task Granularity
- Phases: 2-4 weeks duration
- Work packages: 1-2 weeks duration
- Activities: 1-5 days duration

### 3. Progress Updates
Update task progress regularly (daily for active tasks)

### 4. Evidence Management
Upload evidence as tasks are completed to maintain project documentation

### 5. Dependency Management
Always verify dependencies before marking tasks as completed

## Code Examples

### JavaScript/Node.js

```javascript
// Get project WBS
const response = await fetch(`${API_BASE_URL}/projects/${projectId}/wbs`, {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

const wbsData = await response.json();
console.log('Project WBS:', wbsData.data.wbs_structure);

// Update task progress
const updateResponse = await fetch(`${API_BASE_URL}/tasks/${taskId}`, {
  method: 'PUT',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    progress_percentage: 75,
    status: 'in_progress',
    notes: 'Good progress, on schedule'
  })
});
```

### Flutter/Dart

```dart
// Service class for WBS API
class WBSApiService {
  final Dio _dio;
  
  WBSApiService(this._dio);
  
  Future<WBSStructure> getProjectWBS(String projectId) async {
    final response = await _dio.get('/projects/$projectId/wbs');
    return WBSStructure.fromJson(response.data['data']);
  }
  
  Future<WBSTask> updateTaskProgress(
    String taskId, 
    int progressPercentage,
    TaskStatus status
  ) async {
    final response = await _dio.put('/tasks/$taskId', data: {
      'progress_percentage': progressPercentage,
      'status': status.name,
    });
    return WBSTask.fromJson(response.data['data']);
  }
}
```

### Python

```python
import requests

class WBSClient:
    def __init__(self, base_url, token):
        self.base_url = base_url
        self.headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
    
    def get_project_wbs(self, project_id):
        response = requests.get(
            f'{self.base_url}/projects/{project_id}/wbs',
            headers=self.headers
        )
        return response.json()['data']
    
    def update_task_status(self, task_id, status, notes=None):
        data = {'status': status}
        if notes:
            data['completion_notes'] = notes
            
        response = requests.patch(
            f'{self.base_url}/tasks/{task_id}/status',
            headers=self.headers,
            json=data
        )
        return response.json()
```

## Support

For API support and questions:
- Email: api-support@solar-management.com
- Documentation: https://docs.solar-management.com/wbs-api
- Status Page: https://status.solar-management.com

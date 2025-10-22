#include "utils.h"

typedef struct Node {
    u64 val = -1;
    struct Node* next = nullptr;
    struct Node* prev = nullptr;
    Node(u64 val) {
        this->val = val;
    }
    Node() {

    }

} Node;

typedef struct LinkedList {
    Node* head = new Node();
    Node* tail = new Node();
    LinkedList() {
        head->next = tail;
        tail->prev = head;
    }
} LinkedList;

void addElem(LinkedList& list, u64 const val) {
    auto prev = list.tail->prev;
    auto next = new Node(val);
    prev->next = next;
    next->prev = prev;
    next->next = list.tail;
    list.tail->prev = next;
}

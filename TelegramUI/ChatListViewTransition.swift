import Foundation
import Postbox
import TelegramCore
import SwiftSignalKit
import Display

struct ChatListNodeView {
    let originalView: ChatListView
    let filteredEntries: [ChatListNodeEntry]
}

enum ChatListNodeViewTransitionReason {
    case initial
    case interactiveChanges
    case holeChanges(filledHoleDirections: [MessageIndex: HoleFillDirection], removeHoleDirections: [MessageIndex: HoleFillDirection])
    case reload
}

struct ChatListNodeViewTransitionInsertEntry {
    let index: Int
    let previousIndex: Int?
    let entry: ChatListNodeEntry
    let directionHint: ListViewItemOperationDirectionHint?
}

struct ChatListNodeViewTransitionUpdateEntry {
    let index: Int
    let previousIndex: Int
    let entry: ChatListNodeEntry
    let directionHint: ListViewItemOperationDirectionHint?
}

struct ChatListNodeViewTransition {
    let chatListView: ChatListNodeView
    let deleteItems: [ListViewDeleteItem]
    let insertEntries: [ChatListNodeViewTransitionInsertEntry]
    let updateEntries: [ChatListNodeViewTransitionUpdateEntry]
    let options: ListViewDeleteAndInsertOptions
    let scrollToItem: ListViewScrollToItem?
    let stationaryItemRange: (Int, Int)?
}

enum ChatListNodeViewScrollPosition {
    case index(index: MessageIndex, position: ListViewScrollPosition, directionHint: ListViewScrollToItemDirectionHint, animated: Bool)
}

func preparedChatListNodeViewTransition(from fromView: ChatListNodeView?, to toView: ChatListNodeView, reason: ChatListNodeViewTransitionReason, account: Account, scrollPosition: ChatListNodeViewScrollPosition?) -> Signal<ChatListNodeViewTransition, NoError> {
    return Signal { subscriber in
        let (deleteIndices, indicesAndItems, updateIndices) = mergeListsStableWithUpdates(leftList: fromView?.filteredEntries ?? [], rightList: toView.filteredEntries)
        
        var adjustedDeleteIndices: [ListViewDeleteItem] = []
        let previousCount: Int
        if let fromView = fromView {
            previousCount = fromView.filteredEntries.count
        } else {
            previousCount = 0;
        }
        for index in deleteIndices {
            adjustedDeleteIndices.append(ListViewDeleteItem(index: previousCount - 1 - index, directionHint: nil))
        }
        var adjustedIndicesAndItems: [ChatListNodeViewTransitionInsertEntry] = []
        var adjustedUpdateItems: [ChatListNodeViewTransitionUpdateEntry] = []
        let updatedCount = toView.filteredEntries.count
        
        var options: ListViewDeleteAndInsertOptions = []
        var maxAnimatedInsertionIndex = -1
        var stationaryItemRange: (Int, Int)?
        var scrollToItem: ListViewScrollToItem?
        
        switch reason {
            case .initial:
                let _ = options.insert(.LowLatency)
                let _ = options.insert(.Synchronous)
            case .interactiveChanges:
                let _ = options.insert(.AnimateAlpha)
                let _ = options.insert(.AnimateInsertion)
                
                for (index, _, _) in indicesAndItems.sorted(by: { $0.0 > $1.0 }) {
                    let adjustedIndex = updatedCount - 1 - index
                    if adjustedIndex == maxAnimatedInsertionIndex + 1 {
                        maxAnimatedInsertionIndex += 1
                    }
                }
            case .reload:
                break
            case let .holeChanges(filledHoleDirections, removeHoleDirections):
                if let (_, removeDirection) = removeHoleDirections.first {
                    switch removeDirection {
                    case .LowerToUpper:
                        var holeIndex: MessageIndex?
                        for (index, _) in filledHoleDirections {
                            if holeIndex == nil || index < holeIndex! {
                                holeIndex = index
                            }
                        }
                        
                        if let holeIndex = holeIndex {
                            for i in 0 ..< toView.filteredEntries.count {
                                if toView.filteredEntries[i].index >= holeIndex {
                                    let index = toView.filteredEntries.count - 1 - (i - 1)
                                    stationaryItemRange = (index, Int.max)
                                    break
                                }
                            }
                        }
                    case .UpperToLower:
                        break
                    case .AroundIndex:
                        break
                    }
                }
        }
        
        for (index, entry, previousIndex) in indicesAndItems {
            let adjustedIndex = updatedCount - 1 - index
            
            let adjustedPrevousIndex: Int?
            if let previousIndex = previousIndex {
                adjustedPrevousIndex = previousCount - 1 - previousIndex
            } else {
                adjustedPrevousIndex = nil
            }
            
            var directionHint: ListViewItemOperationDirectionHint?
            if maxAnimatedInsertionIndex >= 0 && adjustedIndex <= maxAnimatedInsertionIndex {
                directionHint = .Down
            }
            
            adjustedIndicesAndItems.append(ChatListNodeViewTransitionInsertEntry(index: adjustedIndex, previousIndex: adjustedPrevousIndex, entry: entry, directionHint: directionHint))
        }
        
        for (index, entry, previousIndex) in updateIndices {
            let adjustedIndex = updatedCount - 1 - index
            let adjustedPreviousIndex = previousCount - 1 - previousIndex
            
            let directionHint: ListViewItemOperationDirectionHint? = nil
            adjustedUpdateItems.append(ChatListNodeViewTransitionUpdateEntry(index: adjustedIndex, previousIndex: adjustedPreviousIndex, entry: entry, directionHint: directionHint))
        }
        
        if let scrollPosition = scrollPosition {
            switch scrollPosition {
                case let .index(scrollIndex, position, directionHint, animated):
                    var index = toView.filteredEntries.count - 1
                    for entry in toView.filteredEntries {
                        if entry.index >= scrollIndex {
                            scrollToItem = ListViewScrollToItem(index: index, position: position, animated: animated, curve: .Default, directionHint: directionHint)
                            break
                        }
                        index -= 1
                    }
                    
                    if scrollToItem == nil {
                        var index = 0
                        for entry in toView.filteredEntries.reversed() {
                            if entry.index < scrollIndex {
                                scrollToItem = ListViewScrollToItem(index: index, position: position, animated: animated, curve: .Default, directionHint: directionHint)
                                break
                            }
                            index += 1
                        }
                    }
            }
        }
        
        subscriber.putNext(ChatListNodeViewTransition(chatListView: toView, deleteItems: adjustedDeleteIndices, insertEntries: adjustedIndicesAndItems, updateEntries: adjustedUpdateItems, options: options, scrollToItem: scrollToItem, stationaryItemRange: stationaryItemRange))
        subscriber.putCompletion()
        
        return EmptyDisposable
    }
}
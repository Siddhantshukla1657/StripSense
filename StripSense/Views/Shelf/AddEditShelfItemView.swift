//
//  AddEditShelfItemView.swift
//  StripSense
//

import SwiftUI

public struct AddEditShelfItemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var shelfService = ShelfService.shared
    @StateObject private var db = DrugDatabaseService.shared
    
    public var itemToEdit: ShelfItem?
    public var prefilledDrug: Drug?
    public var prefilledExpiry: Date?
    public var prefilledBatch: String?
    
    @State private var selectedDrug: Drug?
    @State private var brandName: String = ""
    @State private var dosageForm: String = "Tablet"
    @State private var strength: String = ""
    @State private var hasExpiryDate: Bool = true
    @State private var expiryDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var batchNumber: String = ""
    @State private var notes: String = ""
    
    @State private var showDuplicateAlert: Bool = false
    @State private var duplicateItem: ShelfItem?
    
    public init(
        itemToEdit: ShelfItem? = nil,
        prefilledDrug: Drug? = nil,
        prefilledExpiry: Date? = nil,
        prefilledBatch: String? = nil
    ) {
        self.itemToEdit = itemToEdit
        self.prefilledDrug = prefilledDrug
        self.prefilledExpiry = prefilledExpiry
        self.prefilledBatch = prefilledBatch
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medicine Information")) {
                    if let drug = selectedDrug {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(drug.brand)
                                .font(.headline.weight(.bold))
                            Text(drug.saltsSummary)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(drug.dosageForm) • \(drug.manufacturer)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    } else {
                        TextField("Brand Name (e.g. Dolo 650)", text: $brandName)
                        TextField("Strength (e.g. 650 mg)", text: $strength)
                        Picker("Dosage Form", selection: $dosageForm) {
                            Text("Tablet").tag("Tablet")
                            Text("Capsule").tag("Capsule")
                            Text("Syrup").tag("Syrup")
                            Text("Injection").tag("Injection")
                            Text("Ointment").tag("Ointment")
                            Text("Drops").tag("Drops")
                        }
                    }
                }
                
                Section(header: Text("Expiry Details")) {
                    Toggle("Has Expiry Date", isOn: $hasExpiryDate)
                    
                    if hasExpiryDate {
                        DatePicker("Expiry Month & Year", selection: $expiryDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                    }
                    
                    TextField("Batch Number (Optional)", text: $batchNumber)
                }
                
                Section(header: Text("Personal Notes")) {
                    TextField("E.g. Cabinet top shelf, for family fever", text: $notes)
                }
                
                Section {
                    Button(action: save) {
                        Text(itemToEdit != nil ? "Save Changes" : "Add to Shelf")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle(itemToEdit != nil ? "Edit Medicine" : "Add to Shelf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                setupInitialValues()
            }
            .alert("Already on Shelf", isPresented: $showDuplicateAlert) {
                Button("Update Existing Expiry") {
                    if let dup = duplicateItem {
                        var updated = dup
                        updated.expiryDate = hasExpiryDate ? expiryDate : nil
                        updated.batchNumber = batchNumber.isEmpty ? dup.batchNumber : batchNumber
                        updated.note = notes.isEmpty ? dup.note : notes
                        shelfService.update(item: updated)
                    }
                    dismiss()
                }
                Button("Add as Separate Strip") {
                    forceAddNewItem()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This medicine is already tracked in your shelf. Would you like to update the existing record or add this as a separate strip?")
            }
        }
    }
    
    private func setupInitialValues() {
        if let item = itemToEdit {
            brandName = item.brand
            dosageForm = item.dosageForm
            strength = item.strength
            if let exp = item.expiryDate {
                hasExpiryDate = true
                expiryDate = exp
            } else {
                hasExpiryDate = false
            }
            batchNumber = item.batchNumber ?? ""
            notes = item.note ?? ""
        } else if let drug = prefilledDrug {
            selectedDrug = drug
            brandName = drug.brand
            dosageForm = drug.dosageForm
            strength = drug.strengthSummary
            if let exp = prefilledExpiry {
                hasExpiryDate = true
                expiryDate = exp
            }
            if let batch = prefilledBatch {
                batchNumber = batch
            }
        }
    }
    
    private func save() {
        let drugId = selectedDrug?.id ?? (itemToEdit?.drugId ?? Int.random(in: 10000...99999))
        
        // Check for duplicates if adding fresh
        if itemToEdit == nil, let existing = shelfService.existingItem(for: drugId) {
            duplicateItem = existing
            showDuplicateAlert = true
            return
        }
        
        forceAddNewItem()
        dismiss()
    }
    
    private func forceAddNewItem() {
        if let existing = itemToEdit {
            var updated = existing
            updated.expiryDate = hasExpiryDate ? expiryDate : nil
            updated.batchNumber = batchNumber.isEmpty ? nil : batchNumber
            updated.note = notes.isEmpty ? nil : notes
            shelfService.update(item: updated)
        } else {
            let newItem = ShelfItem(
                drugId: selectedDrug?.id ?? Int.random(in: 10000...99999),
                brand: selectedDrug?.brand ?? (brandName.isEmpty ? "Unknown Medicine" : brandName),
                dosageForm: selectedDrug?.dosageForm ?? dosageForm,
                strength: selectedDrug?.strengthSummary ?? (strength.isEmpty ? "Standard" : strength),
                expiryDate: hasExpiryDate ? expiryDate : nil,
                batchNumber: batchNumber.isEmpty ? nil : batchNumber,
                note: notes.isEmpty ? nil : notes
            )
            shelfService.add(item: newItem)
        }
    }
}

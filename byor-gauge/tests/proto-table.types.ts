export type ProtoTable<T> = {
  rows: Array<ProtoTableRow<T>>;
  headers: ProtoTableRow<T>;
};

export type ProtoTableRow<T> = { cells: T[] };
